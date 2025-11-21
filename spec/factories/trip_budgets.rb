FactoryBot.define do
  factory :trip_budget do
    trip { nil }
    total_trip_cost { "9.99" }
    per_person_cost { "9.99" }
    lodging_total { "9.99" }
    restaurants_total { "9.99" }
    activities_total { "9.99" }
    drinks_total { "9.99" }
    shopping_total { "9.99" }
    other_total { "9.99" }
    currency { "MyString" }
  end
end
