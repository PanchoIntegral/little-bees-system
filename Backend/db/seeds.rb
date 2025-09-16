# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin user if none exists
if User.count == 0
  puts "Creating default admin user..."
  
  User.create!(
    email: 'admin@littlebeescandles.com',
    first_name: 'Admin',
    last_name: 'User',
    role: 'admin',
    password: 'password123',
    password_confirmation: 'password123'
  )
  
  puts "✅ Default admin user created!"
  puts "   Email: admin@littlebeescandles.com"
  puts "   Password: password123"
end

# Create some sample products if none exist
if Product.count == 0
  puts "Creating sample products..."
  
  products = [
    {
      name: 'Vanilla Lavender Candle',
      description: 'A relaxing blend of vanilla and lavender scents',
      price: 24.99,
      sku: 'VL001',
      category: 'candles',
      stock_quantity: 50,
      low_stock_threshold: 10
    },
    {
      name: 'Citrus Burst Candle',
      description: 'Fresh citrus scent perfect for energizing your space',
      price: 22.99,
      sku: 'CB001',
      category: 'candles',
      stock_quantity: 30,
      low_stock_threshold: 8
    },
    {
      name: 'Ocean Breeze Candle',
      description: 'Clean, fresh ocean scent for a calming atmosphere',
      price: 26.99,
      sku: 'OB001',
      category: 'candles',
      stock_quantity: 25,
      low_stock_threshold: 5
    }
  ]
  
  products.each do |product_data|
    Product.create!(product_data)
  end
  
  puts "✅ #{products.length} sample products created!"
end

# Create a sample customer
if Customer.count == 0
  puts "Creating sample customer..."
  
  Customer.create!(
    first_name: 'Jane',
    last_name: 'Doe',
    email: 'jane@example.com',
    phone: '555-0123',
    address: '123 Main St, City, State 12345'
  )
  
  puts "✅ Sample customer created!"
end

puts "🐝 Database seeded successfully!"