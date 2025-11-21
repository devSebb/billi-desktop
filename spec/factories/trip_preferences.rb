FactoryBot.define do
  factory :trip_preference do
    trip { nil }
    lodging_style { "MyString" }
    hotel_nights { 1 }
    airbnb_nights { 1 }
    fancy_restaurant_meals { 1 }
    casual_restaurant_meals { 1 }
    street_food_meals { 1 }
    activities_count { 1 }
    nightlife_nights { 1 }
    shopping_budget_level { "MyString" }
    overall_comfort_level { "MyString" }
    notes { "MyText" }
  end
end
