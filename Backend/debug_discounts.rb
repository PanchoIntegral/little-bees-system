puts "=== Debugging Discounts ==="

item_total = 202.65
puts "Item total: $#{item_total}"

puts "\nAll discounts:"
Discount.all.each do |d|
  puts "- ID: #{d.id}, Name: #{d.name}"
  puts "  Type: #{d.discount_type}, Value: #{d.discount_value}"
  puts "  Min amount: $#{d.minimum_amount}"
  puts "  Active: #{d.active}"
  puts "  Starts at: #{d.starts_at || 'nil'}"
  puts "  Ends at: #{d.ends_at || 'nil'}"
  puts "  Current?: #{d.current?}"
  puts "  Active?: #{d.active?}"
  puts "  Applicable to #{item_total}?: #{d.applicable_to?(item_total)}"
  puts ""
end

puts "\nActive discounts:"
active_discounts = Discount.active
puts "Count: #{active_discounts.count}"
active_discounts.each { |d| puts "- #{d.name}" }

puts "\nCurrent discounts:"
current_discounts = Discount.current
puts "Count: #{current_discounts.count}"
current_discounts.each { |d| puts "- #{d.name}" }

puts "\nActive AND current discounts:"
active_current = Discount.active.current
puts "Count: #{active_current.count}"
active_current.each { |d| puts "- #{d.name}" }

puts "\nDiscounts applicable to $#{item_total}:"
applicable = Discount.active.current.where('minimum_amount <= ?', item_total)
puts "Count: #{applicable.count}"
applicable.each { |d| puts "- #{d.name} (min: $#{d.minimum_amount})" }