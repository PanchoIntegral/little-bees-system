class Api::V1::ProductsController < ActionController::API
  include Response
  include Paginatable

  before_action :set_product, only: [:show, :update, :destroy]

  def index
    # Build base collection with includes for performance
    base_collection = Product.includes(:image_attachment)

    # Apply filters
    filtered_collection = apply_product_filters(base_collection)

    # Apply sorting
    sorted_collection = apply_product_sorting(filtered_collection)

    # Apply pagination with optimizations
    result = paginate_collection(sorted_collection, pagination_params)

    render json: {
      products: result[:collection].as_json(
        methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock, :image_url]
      ),
      pagination: result[:pagination_meta],
      filters_applied: applied_filters_summary
    }
  end

  def show
    render json: @product.as_json(
      methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock, :image_url]
    )
  end

  def create
    Rails.logger.info "Creating product with params: #{product_params.inspect}"
    @product = Product.new(product_params)

    if @product.save
      Rails.logger.info "Product created successfully: #{@product.id}"
      Rails.logger.info "Image attached: #{@product.image.attached?}"
      if @product.image.attached?
        Rails.logger.info "Image filename: #{@product.image.filename}"
        Rails.logger.info "Image content type: #{@product.image.content_type}"
        Rails.logger.info "Image byte size: #{@product.image.byte_size}"
        Rails.logger.info "Generated image URL: #{@product.image_url}"
      end

      response_data = @product.as_json(
        methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock, :image_url]
      )
      Rails.logger.info "Response image_url: #{response_data['image_url']}"

      render json: response_data, status: :created
    else
      Rails.logger.error "Product creation failed: #{@product.errors.full_messages}"
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Exception in create: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { errors: { base: ['An unexpected error occurred'] } }, status: :internal_server_error
  end

  def update
    Rails.logger.info "Updating product #{@product.id} with params: #{product_params.inspect}"

    if @product.update(product_params)
      Rails.logger.info "Product updated successfully: #{@product.id}"
      render json: @product.as_json(
        methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock, :image_url]
      )
    else
      Rails.logger.error "Product update failed: #{@product.errors.full_messages}"
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Exception in update: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { errors: { base: ['An unexpected error occurred'] } }, status: :internal_server_error
  end

  def destroy
    if @product.destroy
      render json: { message: 'Product deleted successfully' }, status: :ok
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :sku, :category,
      :stock_quantity, :low_stock_threshold, :image, :active
    )
  end

  # Enhanced filtering for products
  def apply_product_filters(collection)
    # Text search in name, description, and SKU
    collection = apply_text_search(collection) if params[:search].present?

    # Category filter
    collection = collection.where(category: params[:category]) if params[:category].present?

    # Active status filter
    collection = collection.where(active: params[:active]) if params[:active].present?

    # Stock status filters
    collection = apply_stock_filters(collection)

    # Price range filter
    collection = apply_price_range_filter(collection)

    collection
  end

  def apply_text_search(collection)
    search_term = "%#{params[:search]}%"
    # Use LIKE for SQLite compatibility (case-insensitive search)
    collection.where(
      "LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?) OR LOWER(sku) LIKE LOWER(?)",
      search_term, search_term, search_term
    )
  end

  def apply_stock_filters(collection)
    case params[:stock_status]
    when 'in_stock'
      collection.in_stock
    when 'low_stock'
      collection.low_stock
    when 'out_of_stock'
      collection.out_of_stock
    else
      collection
    end
  end

  def apply_price_range_filter(collection)
    if params[:min_price].present? && params[:max_price].present?
      collection.where(price: params[:min_price].to_f..params[:max_price].to_f)
    elsif params[:min_price].present?
      collection.where('price >= ?', params[:min_price].to_f)
    elsif params[:max_price].present?
      collection.where('price <= ?', params[:max_price].to_f)
    else
      collection
    end
  end

  # Enhanced sorting for products
  def apply_product_sorting(collection)
    sort_by = params[:sort_by] || 'name'
    sort_direction = params[:sort_direction] == 'desc' ? :desc : :asc

    case sort_by
    when 'name'
      collection.order(name: sort_direction)
    when 'price'
      collection.order(price: sort_direction)
    when 'stock'
      collection.order(stock_quantity: sort_direction)
    when 'created_at'
      collection.order(created_at: sort_direction)
    when 'updated_at'
      collection.order(updated_at: sort_direction)
    else
      collection.order(name: :asc)
    end
  end

  # Pagination parameters
  def pagination_params
    {
      page: params[:page],
      per_page: params[:per_page],
      include_total: params[:include_total],
      base_query: nil # Could be used for cursor pagination
    }
  end

  # Summary of applied filters for debugging
  def applied_filters_summary
    filters = {}
    filters[:search] = params[:search] if params[:search].present?
    filters[:category] = params[:category] if params[:category].present?
    filters[:stock_status] = params[:stock_status] if params[:stock_status].present?
    filters[:active] = params[:active] if params[:active].present?
    filters[:price_range] = {
      min: params[:min_price],
      max: params[:max_price]
    } if params[:min_price].present? || params[:max_price].present?

    filters
  end
end