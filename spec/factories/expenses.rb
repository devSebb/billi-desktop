FactoryBot.define do
  factory :expense do
    trip { nil }
    category { "MyString" }
    amount { "9.99" }
    currency { "MyString" }
    spent_at { "2025-11-19" }
    description { "MyString" }
  end
end
