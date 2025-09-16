FactoryBot.define do
  factory :user do
    email { "MyString" }
    first_name { "MyString" }
    last_name { "MyString" }
    role { "MyString" }
    encrypted_password { "MyString" }
    two_factor_secret { "MyString" }
    two_factor_enabled { false }
    phone { "MyString" }
    last_sign_in_at { "2025-09-15 14:24:59" }
  end
end
