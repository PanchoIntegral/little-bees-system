class Api::V1::SalesController < Api::BaseController
  before_action :set_sale, only: [:show, :update, :destroy, :complete, :cancel, :refund]

  def index
    @sales = Sale.includes(:user, :customer, :sale_items, :products).all

    # Apply filters if provided
    @sales = @sales.where(status: params[:status]) if params[:status].present?
    @sales = @sales.where(payment_method: params[:payment_method]) if params[:payment_method].present?
    @sales = @sales.where(user_id: params[:user_id]) if params[:user_id].present?

    # Date range filter
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @sales = @sales.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    # Apply sorting
    case params[:sort_by]
    when 'created_at'
      @sales = @sales.order(created_at: :desc)
    when 'total_amount'
      @sales = @sales.order(:total_amount)
    when 'status'
      @sales = @sales.order(:status)
    else
      @sales = @sales.order(created_at: :desc)
    end

    # Simple pagination
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i
    offset = (page - 1) * per_page

    @sales = @sales.limit(per_page).offset(offset)
    total_count = Sale.count

    render json: {
      sales: @sales.as_json(
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
            }
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
            }
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

  def complete
    if @sale.complete!
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
      :status, :payment_method, :notes, :customer_id,
      sale_items_attributes: [:product_id, :quantity, :unit_price]
    )
  end
end