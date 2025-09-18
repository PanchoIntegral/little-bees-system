puts "=== DEBUGGING CURRENT DISCOUNT STATE ==="

puts "\n1. CHECKING ALL DISCOUNTS IN DATABASE:"
all_discounts = Discount.all
puts "Total discounts in database: #{all_discounts.count}"
all_discounts.each_with_index do |d, index|
  puts "#{index + 1}. ID: #{d.id}"
  puts "   Name: '#{d.name}'"
  puts "   Type: #{d.discount_type}"
  puts "   Value: #{d.discount_value}"
  puts "   Min Amount: $#{d.minimum_amount}"
  puts "   Active: #{d.active}"
  puts "   Starts: #{d.starts_at || 'NULL'}"
  puts "   Ends: #{d.ends_at || 'NULL'}"
  puts "   Created: #{d.created_at}"
  puts ""
end

puts "\n2. CHECKING ACTIVE DISCOUNTS:"
active_discounts = Discount.active
puts "Active discounts: #{active_discounts.count}"
active_discounts.each { |d| puts "- #{d.name}" }

puts "\n3. CHECKING CURRENT DISCOUNTS:"
current_discounts = Discount.current
puts "Current discounts: #{current_discounts.count}"
current_discounts.each { |d| puts "- #{d.name}" }

puts "\n4. CHECKING ACTIVE + CURRENT DISCOUNTS:"
active_current = Discount.active.current
puts "Active AND current discounts: #{active_current.count}"
active_current.each { |d| puts "- #{d.name}" }

puts "\n5. CHECKING RECENT SALES WITH DISCOUNTS:"
recent_sales = Sale.joins(:sale_items)
                   .where('sale_items.discount_amount > 0')
                   .order(created_at: :desc)
                   .limit(5)
                   .includes(:sale_items)

puts "Recent sales with discounts: #{recent_sales.count}"
recent_sales.each do |sale|
  puts "Sale ID: #{sale.id}, Created: #{sale.created_at}"
  sale.sale_items.each do |item|
    if item.discount_amount && item.discount_amount > 0
      puts "  - Item: #{item.product.name}"
      puts "    Quantity: #{item.quantity}, Unit Price: $#{item.unit_price}"
      puts "    Original Total: $#{item.original_total_price}"
      puts "    Discount: $#{item.discount_amount}"
      puts "    Applied Offers: #{item.applied_offers}"
    end
  end
  puts ""
end