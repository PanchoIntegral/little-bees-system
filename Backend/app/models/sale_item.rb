class SaleItem < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product
  
  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  
  validate :product_availability
  validate :line_total_calculation
  
  # Callbacks
  before_validation :calculate_line_total
  before_save :ensure_product_availability
  
  # Scopes
  scope :by_product, ->(product) { where(product: product) }
  scope :recent, -> { joins(:sale).order('sales.created_at DESC') }
  
  # Instance methods
  def total_price
    quantity * unit_price
  end
  
  def product_name
    product.name
  end
  
  def product_sku
    product.sku
  end
  
  def formatted_unit_price
    "$#{unit_price.to_f}"
  end
  
  def formatted_line_total
    "$#{line_total.to_f}"
  end
  
  def discount_applied?
    unit_price < product.price
  end
  
  def discount_amount
    return 0 unless discount_applied?
    (product.price - unit_price) * quantity
  end
  
  def discount_percentage
    return 0 unless discount_applied?
    ((product.price - unit_price) / product.price * 100).round(2)
  end
  
  private
  
  def calculate_line_total
    self.line_total = quantity * unit_price if quantity.present? && unit_price.present?
  end
  
  def product_availability
    return unless product && quantity
    
    unless product.can_sell?(quantity)
      if product.out_of_stock?
        errors.add(:product, "is out of stock")
      else
        errors.add(:quantity, "exceeds available stock (#{product.stock_quantity} available)")
      end
    end
  end
  
  def line_total_calculation
    return unless quantity.present? && unit_price.present? && line_total.present?
    
    expected_total = quantity * unit_price
    unless (line_total - expected_total).abs < 0.01 # Allow for floating point precision
      errors.add(:line_total, "does not match quantity × unit price")
    end
  end
  
  def ensure_product_availability
    return unless new_record? || changed.include?('quantity')
    
    unless product.can_sell?(quantity)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
