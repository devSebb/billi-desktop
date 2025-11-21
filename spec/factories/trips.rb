FactoryBot.define do
  factory :trip do
    user { nil }
    name { "MyString" }
    destination_city { "MyString" }
    destination_country { "MyString" }
    start_date { "2025-11-19" }
    end_date { "2025-11-19" }
    travelers_count { 1 }
    currency { "MyString" }
    status { "MyString" }
  end
end
