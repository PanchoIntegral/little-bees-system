discount = Discount.create!(
  name: 'Test Discount',
  description: 'Test 10% off for orders over $100',
  discount_type: 'percentage',
  discount_value: 10,
  minimum_amount: 100,
  active: true
)

puts "Created discount: #{discount.name} with ID: #{discount.id}"
puts "Discount type: #{discount.discount_type}"
puts "Discount value: #{discount.discount_value}%"
puts "Minimum amount: $#{discount.minimum_amount}"
puts "Active: #{discount.active}"