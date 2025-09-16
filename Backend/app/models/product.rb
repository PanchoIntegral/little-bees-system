class Product < ApplicationRecord
  # Associations
  has_many :sale_items, dependent: :destroy
  has_many :sales, through: :sale_items
  has_one_attached :image
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: /\A[A-Z0-9]+\z/, message: "SKU must contain only uppercase letters and numbers" }
  validates :category, presence: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :low_stock_threshold, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Callbacks
  before_validation :normalize_sku
  before_validation :set_defaults, on: :create
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :out_of_stock, -> { where(stock_quantity: 0) }
  scope :low_stock, -> { where('stock_quantity <= low_stock_threshold AND stock_quantity > 0') }
  scope :by_category, ->(category) { where(category: category) }
  scope :search, ->(query) { where('name ILIKE ? OR description ILIKE ? OR sku ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%") }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :ordered_by_name, -> { order(:name) }
  scope :ordered_by_price, -> { order(:price) }
  scope :ordered_by_stock, -> { order(:stock_quantity) }
  
  # Class methods
  def self.categories
    distinct.pluck(:category).compact.sort
  end
  
  def self.low_stock_count
    low_stock.count
  end
  
  def self.out_of_stock_count
    out_of_stock.count
  end
  
  # Instance methods
  def in_stock?
    stock_quantity > 0
  end
  
  def out_of_stock?
    stock_quantity == 0
  end
  
  def low_stock?
    stock_quantity <= low_stock_threshold && stock_quantity > 0
  end
  
  def stock_status
    return 'out_of_stock' if out_of_stock?
    return 'low_stock' if low_stock?
    'in_stock'
  end
  
  def stock_status_color
    case stock_status
    when 'out_of_stock' then 'red'
    when 'low_stock' then 'yellow'  
    when 'in_stock' then 'green'
    end
  end
  
  def can_sell?(quantity = 1)
    active? && stock_quantity >= quantity
  end
  
  def decrease_stock!(quantity)
    return false unless can_sell?(quantity)
    
    self.stock_quantity -= quantity
    save!
  end
  
  def increase_stock!(quantity)
    self.stock_quantity += quantity
    save!
  end
  
  def formatted_price
    "$#{price.to_f}"
  end

  def image_url
    return nil unless image.attached?

    begin
      # Use our custom API endpoint for serving images
      signed_id = image.signed_id
      if Rails.env.development?
        url = "http://localhost:3000/api/v1/images/#{signed_id}"
        Rails.logger.info "Generated image URL for product #{id}: #{url}"
        return url
      else
        host = Rails.application.config.action_mailer.default_url_options[:host] || 'localhost:3000'
        url = "https://#{host}/api/v1/images/#{signed_id}"
        Rails.logger.info "Generated image URL for product #{id}: #{url}"
        return url
      end
    rescue => e
      Rails.logger.error "Error generating image URL for product #{id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return nil
    end
  end

  # Alias methods for JSON serialization (without question marks)
  def in_stock
    in_stock?
  end

  def out_of_stock
    out_of_stock?
  end

  def low_stock
    low_stock?
  end
  
  def total_sold
    sale_items.sum(:quantity)
  end
  
  def revenue_generated
    sale_items.sum(:line_total)
  end
  
  # Search and filtering
  def self.advanced_search(params)
    results = all
    results = results.search(params[:query]) if params[:query].present?
    results = results.by_category(params[:category]) if params[:category].present?
    results = results.price_range(params[:min_price], params[:max_price]) if params[:min_price].present? && params[:max_price].present?
    results = results.where(active: params[:active]) if params[:active].present?
    
    case params[:stock_status]
    when 'in_stock' then results = results.in_stock
    when 'low_stock' then results = results.low_stock
    when 'out_of_stock' then results = results.out_of_stock
    end
    
    results
  end
  
  private
  
  def normalize_sku
    self.sku = sku.upcase.strip if sku.present?
  end
  
  def set_defaults
    self.active = true if active.nil?
    self.stock_quantity = 0 if stock_quantity.nil?
    self.low_stock_threshold = 5 if low_stock_threshold.nil?
  end
end
