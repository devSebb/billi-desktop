require 'net/http'
require 'json'

module CostOfLiving
  class TravelTablesClient
    BASE_URL = 'https://cost-of-living-and-prices.p.rapidapi.com'

    def initialize
      @api_key = ENV['RAPIDAPI_COST_LIVING_KEY'] || Rails.application.credentials.dig(:rapidapi, :cost_living_key)
      @api_host = ENV['RAPIDAPI_COST_LIVING_HOST'] || 'cost-of-living-and-prices.p.rapidapi.com'
      
      if Rails.env.development? && @api_key.blank?
        Rails.logger.warn "RAPIDAPI_COST_LIVING_KEY is missing. API calls will fail."
      end
    end

    def fetch_city_costs(city_name, country_name)
      # Normalize params if needed, but API usually handles standard names
      uri = URI("#{BASE_URL}/prices")
      uri.query = URI.encode_www_form(city_name: city_name, country_name: country_name)
      
      request = Net::HTTP::Get.new(uri)
      request['X-RapidAPI-Key'] = @api_key
      request['X-RapidAPI-Host'] = @api_host

      begin
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        case response
        when Net::HTTPSuccess
          JSON.parse(response.body)
        else
          Rails.logger.error "TravelTables API Error: #{response.code} #{response.message} - #{response.body}"
          nil
        end
      rescue StandardError => e
        Rails.logger.error "TravelTables Client Error: #{e.message}"
        nil
      end
    end
  end
end

