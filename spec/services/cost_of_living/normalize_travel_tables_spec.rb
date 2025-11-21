require 'rails_helper'

RSpec.describe CostOfLiving::NormalizeTravelTables do
  describe ".call" do
    let(:api_response) do
      {
        "prices" => [
          { "item_name" => "Meal, Inexpensive Restaurant", "average_price" => 15.5, "currency" => "USD" },
          { "item_name" => "Meal for 2 People, Mid-range Restaurant, Three-course", "average_price" => 60.0 },
          { "item_name" => "Domestic Beer (0.5 liter draught)", "average_price" => 5.0 }
        ]
      }
    end

    it "extracts and maps values correctly" do
      result = described_class.call(api_response)
      
      expect(result["food_cheap_meal"]).to eq(15.5)
      expect(result["food_mid_meal"]).to eq(30.0) # 60 / 2
      expect(result["drinks_beer"]).to eq(5.0)
    end
  end
end

