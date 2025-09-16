FactoryBot.define do
  factory :sale_item do
    quantity { 1 }
    unit_price { "9.99" }
    line_total { "9.99" }
    sale { nil }
    product { nil }
  end
end
