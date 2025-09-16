class SaleSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :tax_amount, :discount_amount, :status,
             :payment_method, :notes, :created_at, :updated_at,
             :receipt_number, :subtotal, :items_count, :formatted_total,
             :payment_method_display, :status_display, :customer_name

  belongs_to :user, serializer: UserSerializer
  belongs_to :customer, serializer: CustomerSerializer
  has_many :sale_items, serializer: SaleItemSerializer

  def receipt_number
    object.receipt_number
  end

  def subtotal
    object.subtotal
  end

  def items_count
    object.items_count
  end

  def formatted_total
    object.formatted_total
  end

  def payment_method_display
    object.payment_method_display
  end

  def status_display
    object.status_display
  end

  def customer_name
    object.customer_name
  end
end