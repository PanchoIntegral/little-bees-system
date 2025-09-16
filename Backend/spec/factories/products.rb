FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    sku { "MyString" }
    category { "MyString" }
    stock_quantity { 1 }
    low_stock_threshold { 1 }
    image_url { "MyString" }
    active { false }
  end
end
