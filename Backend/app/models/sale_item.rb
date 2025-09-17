class SaleItem < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Handle applied_offers as JSON
  
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
    (quantity * unit_price) - (discount_amount || 0)
  end

  def original_total_price
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
    (discount_amount || 0) > 0
  end

  def discount_percentage
    return 0 unless discount_applied? && original_total_price > 0
    ((discount_amount || 0) / original_total_price * 100).round(2)
  end

  def formatted_discount_amount
    "$#{(discount_amount || 0).to_f}"
  end

  def applied_offers
    return [] if super.blank?

    if super.is_a?(String)
      JSON.parse(super) rescue []
    else
      super || []
    end
  end

  def applied_offers=(value)
    if value.is_a?(Array) || value.is_a?(Hash)
      super(value.to_json)
    else
      super(value)
    end
  end

  def has_offers?
    applied_offers.present? && applied_offers.any?
  end

  def offer_names
    return [] unless has_offers?
    applied_offers.map { |offer| offer.is_a?(Hash) ? offer['name'] : offer }.compact
  end
  
  private
  
  def calculate_line_total
    if quantity.present? && unit_price.present?
      self.line_total = (quantity * unit_price) - (discount_amount || 0)
    end
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

    expected_total = (quantity * unit_price) - (discount_amount || 0)
    unless (line_total - expected_total).abs < 0.01 # Allow for floating point precision
      errors.add(:line_total, "does not match (quantity × unit price) - discount")
    end
  end
  
  def ensure_product_availability
    return unless new_record? || changed.include?('quantity')
    
    unless product.can_sell?(quantity)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
