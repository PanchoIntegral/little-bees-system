class Sale < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :customer, optional: true # Allow walk-in sales
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
  accepts_nested_attributes_for :sale_items
  
  # Validations
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled refunded] }
  validates :payment_method, presence: true, inclusion: { in: %w[cash credit_card debit_card digital_wallet] }
  
  # Callbacks
  before_validation :calculate_totals, unless: :skip_calculate_totals
  after_create :generate_receipt_number
  after_create :update_product_stock_on_create, if: -> { status == 'completed' }
  after_update :update_product_stock, if: :saved_change_to_status?
  
  attr_accessor :skip_calculate_totals
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :refunded, -> { where(status: 'refunded') }
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(created_at: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :this_month, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_payment_method, ->(method) { where(payment_method: method) }
  scope :by_user, ->(user) { where(user: user) }
  scope :with_customer, -> { where.not(customer_id: nil) }
  scope :walk_in, -> { where(customer_id: nil) }
  
  # Class methods
  def self.daily_revenue(date = Date.current)
    where(created_at: date.beginning_of_day..date.end_of_day)
      .completed
      .sum(:total_amount)
  end
  
  def self.monthly_revenue(date = Date.current)
    where(created_at: date.beginning_of_month..date.end_of_month)
      .completed
      .sum(:total_amount)
  end
  
  def self.revenue_by_period(start_date, end_date)
    where(created_at: start_date..end_date)
      .completed
      .sum(:total_amount)
  end
  
  def self.sales_count_by_period(start_date, end_date)
    where(created_at: start_date..end_date)
      .completed
      .count
  end
  
  def self.average_sale_amount(start_date = 1.month.ago, end_date = Date.current)
    completed_sales = where(created_at: start_date..end_date).completed
    return 0 if completed_sales.empty?
    
    completed_sales.average(:total_amount).to_f
  end
  
  # Instance methods
  def subtotal
    sale_items.to_a.sum { |item| (item.quantity || 0) * (item.unit_price || 0) }
  end
  
  def items_count
    sale_items.sum(:quantity)
  end
  
  def receipt_number
    "LB#{created_at.strftime('%Y%m%d')}#{id.to_s.rjust(4, '0')}"
  end
  
  # Status query methods
  def pending?
    status == 'pending'
  end
  
  def completed?
    status == 'completed'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def refunded?
    status == 'refunded'
  end
  
  def can_be_cancelled?
    pending?
  end
  
  def can_be_completed?
    pending? && sale_items.any?
  end
  
  def can_be_refunded?
    completed? && created_at > 30.days.ago
  end
  
  def complete!
    return false unless can_be_completed?
    
    transaction do
      # Update product stock
      sale_items.each do |item|
        item.product.decrease_stock!(item.quantity)
      end
      
      update!(status: 'completed')
    end
  end
  
  def cancel!
    return false unless can_be_cancelled?
    update!(status: 'cancelled')
  end
  
  def refund!
    return false unless can_be_refunded?
    
    transaction do
      # Restore product stock
      sale_items.each do |item|
        item.product.increase_stock!(item.quantity)
      end
      
      update!(status: 'refunded')
    end
  end
  
  def add_item(product, quantity, unit_price = nil)
    unit_price ||= product.price
    line_total = quantity * unit_price
    
    existing_item = sale_items.find_by(product: product)
    
    if existing_item
      existing_item.update!(
        quantity: existing_item.quantity + quantity,
        line_total: existing_item.line_total + line_total
      )
    else
      sale_items.create!(
        product: product,
        quantity: quantity,
        unit_price: unit_price,
        line_total: line_total
      )
    end
    
    reload
  end
  
  def remove_item(product)
    sale_items.where(product: product).destroy_all
    reload
  end
  
  def apply_discount(discount_amount)
    self.discount_amount = discount_amount
    save!
  end
  
  def customer_name
    customer&.full_name || 'Walk-in Customer'
  end
  
  def formatted_total
    "$#{'%.2f' % total_amount.to_f}"
  end
  
  def payment_method_display
    payment_method.humanize
  end
  
  def status_display
    status.humanize
  end
  
  private
  
  def calculate_totals
    # Calculate subtotal from sale_items (including unsaved ones for nested attributes)
    current_subtotal = calculate_current_subtotal

    current_discount = if discount_amount.present? && discount_amount > 0
                         discount_amount.to_f
                       else
                         calculate_discount_amount(current_subtotal).to_f
                       end
    self.discount_amount = current_discount

    current_tax = if tax_amount.present? && tax_amount > 0
                    tax_amount.to_f
                  else
                    (current_subtotal - current_discount) * 0.08
                  end
    self.tax_amount = current_tax.to_f

    self.total_amount = (current_subtotal + current_tax - current_discount).to_f
  end
  
  def calculate_current_subtotal
    # Use sale_items association which includes both persisted and new items
    total = sale_items.sum { |item| (item.quantity || 0).to_f * (item.unit_price || 0).to_f }
    total.to_f
  end

  def calculate_discount_amount(subtotal_amount)
    # Basic discount logic - can be enhanced later
    return 0.0 if subtotal_amount < 50

    # 10% discount for orders over $100
    return subtotal_amount * 0.10 if subtotal_amount >= 100

    # 5% discount for orders over $50
    return subtotal_amount * 0.05 if subtotal_amount >= 50

    0.0
  end
  
  
  
  def generate_receipt_number
    # Receipt number is generated using the receipt_number method
    # No need to store it as it's calculated dynamically
  end
  
  def update_product_stock_on_create
    # Update product stock when sale is created with completed status
    sale_items.each do |item|
      item.product.decrease_stock!(item.quantity)
    end
  end

  def update_product_stock
    return unless status == 'completed' && saved_change_to_status? && saved_change_to_status[0] == 'pending'

    # Update product stock when sale is completed
    sale_items.each do |item|
      item.product.decrease_stock!(item.quantity)
    end
  end
end
