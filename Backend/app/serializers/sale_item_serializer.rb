class SaleItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :unit_price, :line_total, :created_at, :updated_at

  belongs_to :product, serializer: ProductSerializer
end