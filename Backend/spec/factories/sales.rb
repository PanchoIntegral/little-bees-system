FactoryBot.define do
  factory :sale do
    total_amount { "9.99" }
    tax_amount { "9.99" }
    discount_amount { "9.99" }
    status { "MyString" }
    payment_method { "MyString" }
    notes { "MyText" }
    user { nil }
    customer { nil }
  end
end
