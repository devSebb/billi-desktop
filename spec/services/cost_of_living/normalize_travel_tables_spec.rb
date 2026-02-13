require 'rails_helper'

RSpec.describe CostOfLiving::NormalizeTravelTables do
  describe ".call" do
    context "when API provides usd.avg values" do
      let(:api_response) do
        {
          "prices" => [
            { "item_name" => "Meal, Inexpensive Restaurant", "average_price" => 1200.0, "usd" => { "avg" => "18.50" } },
            { "item_name" => "Meal for 2 People, Mid-range Restaurant, Three-course", "average_price" => 5000.0, "usd" => { "avg" => "75.00" } },
            { "item_name" => "Domestic Beer (0.5 liter draught)", "average_price" => 400.0, "usd" => { "avg" => "6.20" } }
          ]
        }
      end

      it "prefers usd.avg over local average_price" do
        result = described_class.call(api_response)

        expect(result["food_cheap_meal"]).to eq(18.5)
        expect(result["food_mid_meal"]).to eq(37.5) # 75 / 2
        expect(result["drinks_beer"]).to eq(6.2)
      end
    end

    context "when usd.avg is missing (fallback to local)" do
      let(:api_response) do
        {
          "prices" => [
            { "item_name" => "Meal, Inexpensive Restaurant", "average_price" => 15.5 },
            { "item_name" => "Meal for 2 People, Mid-range Restaurant, Three-course", "average_price" => 60.0 },
            { "item_name" => "Domestic Beer (0.5 liter draught)", "average_price" => 5.0 }
          ]
        }
      end

      it "falls back to local average_price" do
        result = described_class.call(api_response)

        expect(result["food_cheap_meal"]).to eq(15.5)
        expect(result["food_mid_meal"]).to eq(30.0) # 60 / 2
        expect(result["drinks_beer"]).to eq(5.0)
      end
    end

    context "when usd.avg contains comma-formatted strings" do
      let(:api_response) do
        {
          "prices" => [
            { "item_name" => "Apartment (1 bedroom) in City Centre", "usd" => { "avg" => "1,234.56" } }
          ]
        }
      end

      it "parses the string correctly" do
        result = described_class.call(api_response)

        expect(result["stay_rent_1br_center_month"]).to eq(1234.56)
      end
    end

    context "with empty response" do
      it "returns empty hash for nil response" do
        expect(described_class.call(nil)).to eq({})
      end

      it "returns empty hash for empty prices" do
        expect(described_class.call({ "prices" => [] })).to eq({})
      end
    end
  end
end
