class Api::V1::SalesController < Api::BaseController
  include Paginatable

  before_action :set_sale, only: [:show, :update, :destroy, :complete, :cancel, :refund]

  def index
    # Build base collection with optimized includes
    base_collection = Sale.includes(:user, :customer, sale_items: :product)

    # Apply filters
    filtered_collection = apply_sales_filters(base_collection)

    # Apply sorting
    sorted_collection = apply_sales_sorting(filtered_collection)

    # Apply pagination with optimizations
    result = paginate_collection(sorted_collection, pagination_params)

    render json: {
      sales: result[:collection].as_json(
        include: {
          user: { only: [:id, :email, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name, :email] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            },
            methods: [:discount_applied?, :formatted_discount_amount, :offer_names, :original_total_price]
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      ),
      pagination: result[:pagination_meta],
      filters_applied: applied_sales_filters_summary
    }
  end

  def show
    render json: @sale.as_json(
      include: {
        user: { only: [:id, :email, :first_name, :last_name] },
        customer: { only: [:id, :first_name, :last_name, :email] },
        sale_items: {
          include: {
            product: { only: [:id, :name, :sku, :price] }
          }
        }
      },
      methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
    )
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.user = current_user || User.first # Fallback to first user if no current_user

    if @sale.save
      render json: @sale.as_json(
        include: {
          user: { only: [:id, :email, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name, :email] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            },
            methods: [:discount_applied?, :formatted_discount_amount, :offer_names, :original_total_price]
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      ), status: :created
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @sale.update(sale_params)
      render json: @sale.as_json(
        include: {
          user: { only: [:id, :email, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name, :email] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            },
            methods: [:discount_applied?, :formatted_discount_amount, :offer_names, :original_total_price]
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @sale.destroy
      render json: { message: 'Sale deleted successfully' }, status: :ok
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end

  def destroy_all
    # Only allow admins to delete all sales
    unless current_user&.admin?
      render json: { error: 'Unauthorized. Admin access required.' }, status: :forbidden
      return
    end

    begin
      deleted_count = Sale.count
      Sale.destroy_all

      render json: {
        message: "Successfully deleted all #{deleted_count} sales",
        deleted_count: deleted_count
      }, status: :ok
    rescue StandardError => e
      render json: {
        error: 'Failed to delete sales',
        details: e.message
      }, status: :unprocessable_entity
    end
  end

  def complete
    if @sale.complete!
      render json: @sale.as_json(
        include: {
          user: { only: [:id, :email, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name, :email] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            },
            methods: [:discount_applied?, :formatted_discount_amount, :offer_names, :original_total_price]
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end
  

  def cancel
    if @sale.cancel!
      render json: @sale.as_json(
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end

  def refund
    if @sale.refund!
      render json: @sale.as_json(
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale.errors }, status: :unprocessable_entity
    end
  end

  # Dashboard stats
  def stats
    today = Date.current
    this_month = today.beginning_of_month..today.end_of_month

    # Calculate real statistics
    today_sales = Sale.where(created_at: today.beginning_of_day..today.end_of_day).where(status: 'completed')
    month_sales = Sale.where(created_at: this_month).where(status: 'completed')

    # Payment method statistics for this month
    payment_methods_stats = calculate_payment_method_stats(month_sales)

    # Get recent sales
    recent_sales = Sale.includes(:user, :customer)
                      .order(created_at: :desc)
                      .limit(5)

    stats = {
      today: {
        sales_count: today_sales.count,
        revenue: today_sales.sum(:total_amount).to_f
      },
      this_month: {
        sales_count: month_sales.count,
        revenue: month_sales.sum(:total_amount).to_f
      },
      average_sale: month_sales.any? ? (month_sales.average(:total_amount).to_f) : 0,
      payment_methods: payment_methods_stats,
      recent_sales: recent_sales.as_json(
        include: {
          user: { only: [:id, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name] }
        },
        methods: [:receipt_number, :formatted_total, :customer_name]
      )
    }

    render json: stats
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sale not found' }, status: :not_found
  end

  def sale_params
    params.require(:sale).permit(
      :status, :payment_method, :notes, :customer_id, :anonymous_customer_name,
      sale_items_attributes: [:product_id, :quantity, :unit_price, :discount_amount, applied_offers: []]
    )
  end

  # Enhanced filtering for sales
  def apply_sales_filters(collection)
    # Status filter
    collection = collection.where(status: params[:status]) if params[:status].present?

    # Payment method filter
    collection = collection.where(payment_method: params[:payment_method]) if params[:payment_method].present?

    # User filter
    collection = collection.where(user_id: params[:user_id]) if params[:user_id].present?

    # Customer filter
    collection = collection.where(customer_id: params[:customer_id]) if params[:customer_id].present?

    # Date range filter
    collection = apply_sales_date_filter(collection)

    # Amount range filter
    collection = apply_amount_range_filter(collection)

    # Search filter (by receipt number or customer name)
    collection = apply_sales_search(collection) if params[:search].present?

    collection
  end

  def apply_sales_date_filter(collection)
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      collection.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    elsif params[:date_filter].present?
      # Predefined date filters
      case params[:date_filter]
      when 'today'
        collection.today
      when 'this_week'
        collection.this_week
      when 'this_month'
        collection.this_month
      else
        collection
      end
    else
      collection
    end
  end

  def apply_amount_range_filter(collection)
    if params[:min_amount].present? && params[:max_amount].present?
      collection.where(total_amount: params[:min_amount].to_f..params[:max_amount].to_f)
    elsif params[:min_amount].present?
      collection.where('total_amount >= ?', params[:min_amount].to_f)
    elsif params[:max_amount].present?
      collection.where('total_amount <= ?', params[:max_amount].to_f)
    else
      collection
    end
  end

  def apply_sales_search(collection)
    search_term = "%#{params[:search]}%"
    # Search in receipt numbers and join with customers for name search (SQLite compatible)
    collection.left_joins(:customer)
              .where(
                "CAST(sales.id AS TEXT) LIKE ? OR LOWER(customers.first_name) LIKE LOWER(?) OR LOWER(customers.last_name) LIKE LOWER(?)",
                search_term, search_term, search_term
              )
  end

  # Enhanced sorting for sales
  def apply_sales_sorting(collection)
    sort_by = params[:sort_by] || 'created_at'
    sort_direction = params[:sort_direction] == 'asc' ? :asc : :desc

    case sort_by
    when 'created_at'
      collection.order(created_at: sort_direction)
    when 'total_amount'
      collection.order(total_amount: sort_direction)
    when 'status'
      collection.order(status: sort_direction)
    when 'payment_method'
      collection.order(payment_method: sort_direction)
    when 'customer_name'
      collection.left_joins(:customer)
                .order("COALESCE(customers.first_name || ' ' || customers.last_name, 'Walk-in Customer') #{sort_direction}")
    else
      collection.order(created_at: :desc)
    end
  end

  # Pagination parameters for sales
  def pagination_params
    {
      page: params[:page],
      per_page: params[:per_page],
      include_total: params[:include_total],
      base_query: nil
    }
  end

  # Summary of applied filters for debugging
  def applied_sales_filters_summary
    filters = {}
    filters[:status] = params[:status] if params[:status].present?
    filters[:payment_method] = params[:payment_method] if params[:payment_method].present?
    filters[:user_id] = params[:user_id] if params[:user_id].present?
    filters[:customer_id] = params[:customer_id] if params[:customer_id].present?
    filters[:search] = params[:search] if params[:search].present?
    filters[:date_range] = {
      start: params[:start_date],
      end: params[:end_date],
      filter: params[:date_filter]
    } if params[:start_date].present? || params[:end_date].present? || params[:date_filter].present?
    filters[:amount_range] = {
      min: params[:min_amount],
      max: params[:max_amount]
    } if params[:min_amount].present? || params[:max_amount].present?

    filters
  end

  def calculate_payment_method_stats(sales_collection)
    # Get all payment methods defined in the model
    payment_methods = %w[cash credit_card debit_card digital_wallet]

    # Calculate stats for each payment method
    stats = {}
    total_revenue = sales_collection.sum(:total_amount).to_f
    total_count = sales_collection.count

    payment_methods.each do |method|
      method_sales = sales_collection.where(payment_method: method)
      method_revenue = method_sales.sum(:total_amount).to_f
      method_count = method_sales.count

      stats[method] = {
        count: method_count,
        revenue: method_revenue,
        percentage: total_revenue > 0 ? ((method_revenue / total_revenue) * 100).round(2) : 0,
        average_amount: method_count > 0 ? (method_revenue / method_count).round(2) : 0,
        display_name: format_payment_method_name(method)
      }
    end

    # Add summary
    stats[:summary] = {
      total_sales: total_count,
      total_revenue: total_revenue,
      most_used_method: stats.except(:summary).max_by { |_, data| data[:count] }&.first,
      highest_revenue_method: stats.except(:summary).max_by { |_, data| data[:revenue] }&.first
    }

    stats
  end

  def format_payment_method_name(method)
    case method
    when 'cash'
      'Efectivo'
    when 'credit_card'
      'Tarjeta de Crédito'
    when 'debit_card'
      'Tarjeta de Débito'
    when 'digital_wallet'
      'Billetera Digital'
    else
      method.humanize
    end
  end
end