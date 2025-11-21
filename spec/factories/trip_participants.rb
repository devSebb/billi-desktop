FactoryBot.define do
  factory :trip_participant do
    trip { nil }
    user { nil }
    name { "MyString" }
    email { "MyString" }
    is_user { false }
  end
end
