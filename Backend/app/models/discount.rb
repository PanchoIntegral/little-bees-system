class Discount < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :discount_type, presence: true, inclusion: { in: %w[percentage fixed_amount] }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :minimum_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :discount_value_within_limits
  validate :valid_date_range
  
  # Callbacks
  before_validation :set_defaults, on: :create
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, -> { where('starts_at <= ? AND (ends_at IS NULL OR ends_at >= ?)', Time.current, Time.current) }
  scope :upcoming, -> { where('starts_at > ?', Time.current) }
  scope :expired, -> { where('ends_at < ?', Time.current) }
  scope :percentage_type, -> { where(discount_type: 'percentage') }
  scope :fixed_amount_type, -> { where(discount_type: 'fixed_amount') }
  scope :applicable_to_amount, ->(amount) { where('minimum_amount <= ?', amount) }
  
  # Class methods
  def self.available_for_sale(sale_amount)
    active.current.applicable_to_amount(sale_amount)
  end
  
  def self.best_discount_for_amount(amount)
    applicable_discounts = available_for_sale(amount)
    
    best_discount = nil
    max_savings = 0
    
    applicable_discounts.each do |discount|
      savings = discount.calculate_discount(amount)
      if savings > max_savings
        max_savings = savings
        best_discount = discount
      end
    end
    
    best_discount
  end
  
  # Instance methods
  def percentage?
    discount_type == 'percentage'
  end
  
  def fixed_amount?
    discount_type == 'fixed_amount'
  end
  
  def active?
    active && current?
  end
  
  def current?
    return false if starts_at && starts_at > Time.current
    return false if ends_at && ends_at < Time.current
    true
  end
  
  def upcoming?
    starts_at && starts_at > Time.current
  end
  
  def expired?
    ends_at && ends_at < Time.current
  end
  
  def applicable_to?(sale_amount)
    active? && sale_amount >= minimum_amount
  end
  
  def calculate_discount(sale_amount)
    return 0 unless applicable_to?(sale_amount)
    
    case discount_type
    when 'percentage'
      (sale_amount * discount_value / 100).round(2)
    when 'fixed_amount'
      [discount_value, sale_amount].min
    else
      0
    end
  end
  
  def final_amount_after_discount(sale_amount)
    sale_amount - calculate_discount(sale_amount)
  end
  
  def savings_display(sale_amount)
    savings = calculate_discount(sale_amount)
    return "$0.00" if savings.zero?
    
    case discount_type
    when 'percentage'
      "#{discount_value}% off ($#{savings})"
    when 'fixed_amount'
      "$#{savings} off"
    end
  end
  
  def discount_display
    case discount_type
    when 'percentage'
      "#{discount_value}% off"
    when 'fixed_amount'
      "$#{discount_value} off"
    end
  end
  
  def status_display
    return 'Inactive' unless active
    return 'Upcoming' if upcoming?
    return 'Expired' if expired?
    'Active'
  end
  
  def duration_display
    return 'No end date' unless ends_at
    
    if starts_at
      "#{starts_at.strftime('%b %d, %Y')} - #{ends_at.strftime('%b %d, %Y')}"
    else
      "Until #{ends_at.strftime('%b %d, %Y')}"
    end
  end
  
  def minimum_amount_display
    minimum_amount.zero? ? 'No minimum' : "$#{minimum_amount}"
  end
  
  def activate!
    update!(active: true)
  end
  
  def deactivate!
    update!(active: false)
  end
  
  private
  
  def set_defaults
    self.active = true if active.nil?
    self.minimum_amount = 0 if minimum_amount.nil?
  end
  
  def discount_value_within_limits
    case discount_type
    when 'percentage'
      if discount_value && (discount_value <= 0 || discount_value > 100)
        errors.add(:discount_value, 'must be between 1 and 100 for percentage discounts')
      end
    when 'fixed_amount'
      if discount_value && discount_value <= 0
        errors.add(:discount_value, 'must be greater than 0 for fixed amount discounts')
      end
    end
  end
  
  def valid_date_range
    return unless starts_at && ends_at
    
    if ends_at <= starts_at
      errors.add(:ends_at, 'must be after start date')
    end
  end
end
