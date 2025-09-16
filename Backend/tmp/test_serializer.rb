product = Product.first
serializer = ProductSerializer.new(product)
puts "Serialized product:"
puts serializer.to_json