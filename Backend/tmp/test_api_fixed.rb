# Test the controller logic with correct method names
products = Product.all
puts "Products query works: #{products.count} product(s)"

# Test as_json with correct methods
json_data = products.as_json(
  methods: [:formatted_price, :stock_status, :stock_status_color, :in_stock?, :out_of_stock?, :low_stock?]
)
puts "JSON serialization works"
puts "Keys: #{json_data.first.keys.sort}"

# Clean up
Product.delete_all
puts "Test product cleaned"