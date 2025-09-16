class Api::V1::SaleItemsController < Api::BaseController
  before_action :set_sale
  before_action :set_sale_item, only: [:update, :destroy]

  def create
    @product = Product.find(params[:sale_item][:product_id])
    quantity = params[:sale_item][:quantity].to_i
    unit_price = (params[:sale_item][:unit_price] || @product.price).to_f

    # Check if product can be sold
    unless @product.can_sell?(quantity)
      return render json: {
        error: "Insufficient stock. Available: #{@product.stock_quantity}"
      }, status: :unprocessable_entity
    end

    # Check if item already exists in sale
    existing_item = @sale.sale_items.find_by(product: @product)

    if existing_item
      # Update existing item
      new_quantity = existing_item.quantity + quantity
      new_line_total = new_quantity * unit_price.to_f

      if existing_item.update(quantity: new_quantity, line_total: new_line_total)
        @sale.reload
        render json: @sale.as_json(
          include: {
            user: { only: [:id, :first_name, :last_name] },
            customer: { only: [:id, :first_name, :last_name] },
            sale_items: {
              include: {
                product: { only: [:id, :name, :sku, :price] }
              }
            }
          },
          methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
        ), status: :created
      else
        render json: { errors: existing_item.errors }, status: :unprocessable_entity
      end
    else
      # Create new item
      @sale_item = @sale.sale_items.build(
        product: @product,
        quantity: quantity,
        unit_price: unit_price.to_f,
        line_total: quantity * unit_price.to_f
      )

      if @sale_item.save
        @sale.reload
        render json: @sale.as_json(
          include: {
            user: { only: [:id, :first_name, :last_name] },
            customer: { only: [:id, :first_name, :last_name] },
            sale_items: {
              include: {
                product: { only: [:id, :name, :sku, :price] }
              }
            }
          },
          methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
        ), status: :created
      else
        render json: { errors: @sale_item.errors }, status: :unprocessable_entity
      end
    end
  end

  def update
    if @sale_item.update(sale_item_params)
      # Recalculate line total
      @sale_item.update(line_total: @sale_item.quantity * @sale_item.unit_price.to_f)
      @sale.reload

      render json: @sale.as_json(
        include: {
          user: { only: [:id, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            }
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale_item.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @sale_item.destroy
      @sale.reload
      render json: @sale.as_json(
        include: {
          user: { only: [:id, :first_name, :last_name] },
          customer: { only: [:id, :first_name, :last_name] },
          sale_items: {
            include: {
              product: { only: [:id, :name, :sku, :price] }
            }
          }
        },
        methods: [:receipt_number, :subtotal, :items_count, :formatted_total, :customer_name]
      )
    else
      render json: { errors: @sale_item.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_sale
    @sale = Sale.find(params[:sale_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sale not found' }, status: :not_found
  end

  def set_sale_item
    @sale_item = @sale.sale_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sale item not found' }, status: :not_found
  end

  def sale_item_params
    params.require(:sale_item).permit(:quantity, :unit_price)
  end
end