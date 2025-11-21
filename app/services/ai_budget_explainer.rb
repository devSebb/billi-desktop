class AiBudgetExplainer
  def self.explain(trip, budget)
    new(trip, budget).explain
  end

  def initialize(trip, budget)
    @trip = trip
    @budget = budget
  end

  def explain
    # TODO: Integrate with OpenAI API here.
    # Example:
    # client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    # prompt = "Analyze this travel budget for #{@trip.destination_city}: #{budget_json}..."
    # response = client.chat(parameters: { model: "gpt-4", messages: [{ role: "user", content: prompt }] })
    # return response.dig("choices", 0, "message", "content")
    
    # Fake implementation for MVP
    generate_fake_response
  end

  private

  def generate_fake_response
    diff_msg = if @budget.per_person_cost > 2000
                 "This is on the higher side, mostly driven by your premium lodging choices."
               else
                 "This is a very efficient budget! You are saving a lot on food."
               end

    "Billi's Analysis: For a #{@trip.trip_preference.overall_comfort_level} trip to #{@trip.destination_city} in #{@trip.start_date.strftime('%B')}, a total of #{ActiveSupport::NumberHelper.number_to_currency(@budget.total_trip_cost)} is expected. #{diff_msg} Try reducing fancy meals to save ~15%."
  end
end

