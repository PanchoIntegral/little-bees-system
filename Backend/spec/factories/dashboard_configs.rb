FactoryBot.define do
  factory :dashboard_config do
    user { nil }
    config { "MyText" }
    layout_name { "MyString" }
    active { false }
  end
end
