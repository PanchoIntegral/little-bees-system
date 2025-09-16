# Test if the controller loads without errors
begin
  require_relative '../app/controllers/api/v1/products_controller'
  puts "ProductsController loaded successfully"
rescue => e
  puts "Error loading ProductsController: #{e.message}"
  puts e.backtrace.first(5)
end

# Test if Kaminari is working
begin
  result = Product.page(1).per(20)
  puts "Kaminari pagination works"
rescue => e
  puts "Kaminari error: #{e.message}"
end