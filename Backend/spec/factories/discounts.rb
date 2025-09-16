FactoryBot.define do
  factory :discount do
    name { "MyString" }
    description { "MyText" }
    discount_type { "MyString" }
    discount_value { "9.99" }
    minimum_amount { "9.99" }
    active { false }
    starts_at { "2025-09-15 14:47:52" }
    ends_at { "2025-09-15 14:47:52" }
  end
end
