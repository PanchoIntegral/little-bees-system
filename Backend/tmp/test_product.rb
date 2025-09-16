p = Product.create!(
  name: 'Test Candle',
  price: 10.99,
  sku: 'TEST001',
  category: 'Test',
  stock_quantity: 10
)
puts "Product created: #{p.name} (ID: #{p.id})"
puts "Products count: #{Product.count}"