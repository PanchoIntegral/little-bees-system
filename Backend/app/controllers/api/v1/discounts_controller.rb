class Api::V1::DiscountsController < Api::BaseController
  before_action :set_discount, only: [:show, :update, :destroy]

  def index
    @discounts = Discount.all

    # Apply filters if provided
    @discounts = @discounts.where(active: params[:active]) if params[:active].present?
    @discounts = @discounts.where(discount_type: params[:discount_type]) if params[:discount_type].present?

    # Apply sorting
    case params[:sort_by]
    when 'name'
      @discounts = @discounts.order(:name)
    when 'discount_value'
      @discounts = @discounts.order(:discount_value)
    when 'created_at'
      @discounts = @discounts.order(:created_at)
    else
      @discounts = @discounts.order(:name)
    end

    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @discounts = @discounts.page(page).per(per_page)

    render json: {
      discounts: ActiveModel::Serializer::CollectionSerializer.new(@discounts, serializer: DiscountSerializer),
      pagination: {
        current_page: @discounts.current_page,
        total_pages: @discounts.total_pages,
        total_count: @discounts.total_count,
        per_page: @discounts.limit_value
      }
    }
  end

  def show
    render json: @discount, serializer: DiscountSerializer
  end

  def create
    @discount = Discount.new(discount_params)

    if @discount.save
      render json: @discount, serializer: DiscountSerializer, status: :created
    else
      render json: { errors: @discount.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @discount.update(discount_params)
      render json: @discount, serializer: DiscountSerializer
    else
      render json: { errors: @discount.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @discount.destroy
      render json: { message: 'Discount deleted successfully' }, status: :ok
    else
      render json: { errors: @discount.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_discount
    @discount = Discount.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Discount not found' }, status: :not_found
  end

  def discount_params
    params.require(:discount).permit(
      :name, :description, :discount_type, :discount_value,
      :minimum_amount, :active, :starts_at, :ends_at
    )
  end
end