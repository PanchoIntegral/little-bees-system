class Api::V1::CustomersController < Api::BaseController
  before_action :set_customer, only: [:show, :update, :destroy]

  def index
    @customers = Customer.all

    # Apply search filter if provided
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @customers = @customers.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR phone ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # Apply sorting
    case params[:sort_by]
    when 'name'
      @customers = @customers.order(:first_name, :last_name)
    when 'email'
      @customers = @customers.order(:email)
    when 'created_at'
      @customers = @customers.order(:created_at)
    else
      @customers = @customers.order(:first_name, :last_name)
    end

    # Simple pagination
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i
    offset = (page - 1) * per_page

    @customers = @customers.limit(per_page).offset(offset)
    total_count = Customer.count

    render json: {
      customers: @customers.as_json(
        methods: [:full_name]
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
    render json: @customer.as_json(
      methods: [:full_name]
    )
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render json: @customer.as_json(
        methods: [:full_name]
      ), status: :created
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: @customer.as_json(
        methods: [:full_name]
      )
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      render json: { message: 'Customer deleted successfully' }, status: :ok
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Customer not found' }, status: :not_found
  end

  def customer_params
    params.require(:customer).permit(
      :first_name, :last_name, :email, :phone, :address
    )
  end
end