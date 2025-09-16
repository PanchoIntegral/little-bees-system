class Customer < ApplicationRecord
  # Associations
  has_many :sales, dependent: :destroy
  has_many :sale_items, through: :sales
  has_many :products, through: :sale_items
  
  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A[\+]?[\d\s\-\(\)]+\z/, message: "Invalid phone format" },
            allow_blank: true
  validate :at_least_one_contact_method
  
  # Callbacks
  before_save :normalize_email
  before_save :normalize_phone
  
  # Scopes
  scope :with_email, -> { where.not(email: [nil, '']) }
  scope :with_phone, -> { where.not(phone: [nil, '']) }
  scope :recent, -> { order(created_at: :desc) }
  scope :frequent, -> { joins(:sales).group('customers.id').having('COUNT(sales.id) >= ?', 5) }
  scope :search, ->(query) do
    where('first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR phone ILIKE ?',
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  end
  
  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def display_name
    full_name
  end
  
  def total_purchases
    sales.completed.sum(:total_amount)
  end
  
  def total_orders
    sales.completed.count
  end
  
  def average_order_value
    completed_sales = sales.completed
    return 0 if completed_sales.empty?
    
    completed_sales.average(:total_amount).to_f
  end
  
  def last_purchase_date
    sales.completed.maximum(:created_at)
  end
  
  def days_since_last_purchase
    return nil unless last_purchase_date
    (Date.current - last_purchase_date.to_date).to_i
  end
  
  def frequent_customer?
    total_orders >= 5
  end
  
  def vip_customer?
    total_purchases >= 1000 || total_orders >= 20
  end
  
  def customer_tier
    case
    when vip_customer? then 'VIP'
    when frequent_customer? then 'Frequent'
    else 'Regular'
    end
  end
  
  def favorite_products(limit = 5)
    products
      .joins(:sale_items)
      .where(sales: { status: 'completed' })
      .group('products.id')
      .order('SUM(sale_items.quantity) DESC')
      .limit(limit)
  end
  
  def contact_methods
    methods = []
    methods << email if email.present?
    methods << phone if phone.present?
    methods
  end
  
  def primary_contact
    email.present? ? email : phone
  end
  
  def formatted_total_purchases
    "$#{total_purchases.to_f}"
  end
  
  def recent_purchases(limit = 5)
    sales.completed.includes(:sale_items, :products).order(created_at: :desc).limit(limit)
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def normalize_phone
    self.phone = phone.gsub(/[^\d\+]/, '') if phone.present?
  end
  
  def at_least_one_contact_method
    if email.blank? && phone.blank?
      errors.add(:base, "Must provide either email or phone number")
    end
  end
end
