class Api::V1::ProductsController < ActionController::API
  include Response

  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @products = Product.all

    # Apply filters if provided
    @products = @products.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where(active: params[:active]) if params[:active].present?

    case params[:stock_status]
    when 'in_stock'
      @products = @products.where('stock_quantity > 0')
    when 'low_stock'
      @products = @products.where('stock_quantity <= low_stock_threshold AND stock_quantity > 0')
    when 'out_of_stock'
      @products = @products.where(stock_quantity: 0)
    end

    # Apply sorting
    case params[:sort_by]
    when 'name'
      @products = @products.order(:name)
    when 'price'
      @products = @products.order(:price)
    when 'stock'
      @products = @products.order(:stock_quantity)
    else
      @products = @products.order(:name)
    end

    # Simple pagination
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i
    offset = (page - 1) * per_page

    @products = @products.limit(per_page).offset(offset)
    total_count = Product.count

    render json: {
      products: @products.as_json(
        methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock, :image_url]
      ),
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
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
end