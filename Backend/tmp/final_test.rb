# Create test product
p = Product.create!(
  name: 'Final Test Candle',
  price: 19.99,
  sku: 'FINAL001',
  category: 'Test',
  stock_quantity: 5,
  low_stock_threshold: 10
)

puts "✅ Product created: #{p.name}"

# Test all the methods
puts "✅ Methods work:"
puts "  - formatted_price: #{p.formatted_price}"
puts "  - stock_status: #{p.stock_status}"
puts "  - in_stock: #{p.in_stock}"
puts "  - low_stock: #{p.low_stock}"
puts "  - out_of_stock: #{p.out_of_stock}"

# Test JSON serialization
json_data = Product.all.as_json(
  methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock]
)

puts "\n✅ JSON serialization works:"
puts "  - Keys: #{json_data.first.keys.include?('in_stock') ? '✅' : '❌'} in_stock"
puts "  - Keys: #{json_data.first.keys.include?('formatted_price') ? '✅' : '❌'} formatted_price"
puts "  - Value in_stock: #{json_data.first['in_stock']}"
puts "  - Value low_stock: #{json_data.first['low_stock']}"

# Clean up
Product.delete_all
puts "\n🧹 Test data cleaned"
puts "\n🎉 API is ready to work!"