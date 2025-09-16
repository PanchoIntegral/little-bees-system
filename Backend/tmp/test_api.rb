# Create a test product
p = Product.create!(
  name: 'Test Candle API',
  price: 15.99,
  sku: 'TESTAPI001',
  category: 'Test Category',
  stock_quantity: 25
)

puts "Test product created: #{p.name} (ID: #{p.id})"
puts "Product methods work:"
puts "- formatted_price: #{p.formatted_price}"
puts "- stock_status: #{p.stock_status}"
puts "- in_stock: #{p.in_stock?}"

# Test the controller logic
products = Product.all
puts "\nProducts query works: #{products.count} product(s)"

# Test as_json with methods
json_data = products.as_json(
  methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock, :out_of_stock, :low_stock]
)
puts "\nJSON serialization works"
puts json_data.first.keys.sort