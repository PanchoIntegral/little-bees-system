class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :sku, :category,
             :stock_quantity, :low_stock_threshold, :active,
             :created_at, :updated_at, :formatted_price, :stock_status,
             :stock_status_color, :in_stock, :out_of_stock, :low_stock,
             :total_sold, :revenue_generated, :image_url

  def image_url
    object.image_url
  end

  def formatted_price
    object.formatted_price
  end

  def stock_status
    object.stock_status
  end

  def stock_status_color
    object.stock_status_color
  end

  def in_stock
    object.in_stock?
  end

  def out_of_stock
    object.out_of_stock?
  end

  def low_stock
    object.low_stock?
  end

  def total_sold
    object.total_sold
  end

  def revenue_generated
    object.revenue_generated
  end
end