require 'net/http'
require 'openssl'
require 'json'

module CostOfLiving
  class RateLimitError < StandardError
    attr_reader :code, :retry_after, :body

    def initialize(code:, retry_after: nil, body: nil)
      @code = code
      @retry_after = retry_after
      @body = body
      retry_msg = retry_after ? "#{retry_after} seconds" : "not specified (try again in 1 hour or check RapidAPI quota)"
      msg = "Rate Limit Exceeded (429). Retry after: #{retry_msg}"
      super(msg)
    end
  end

  class TravelTablesClient
    BASE_URL = 'https://cost-of-living-and-prices.p.rapidapi.com'

    def initialize
      @api_key = ENV['RAPIDAPI_COST_LIVING_KEY'] || Rails.application.credentials.dig(:rapidapi, :cost_living_key)
      @api_host = ENV['RAPIDAPI_COST_LIVING_HOST'] || 'cost-of-living-and-prices.p.rapidapi.com'
      # Opt-in workaround for "certificate verify failed (unable to get certificate CRL)" on some macOS/Ruby setups
      @skip_ssl_verify = %w[1 true yes].include?(ENV['COST_OF_LIVING_SKIP_SSL_VERIFY'].to_s.downcase)

      if Rails.env.development? && @api_key.blank?
        Rails.logger.warn "RAPIDAPI_COST_LIVING_KEY is missing. API calls will fail."
      end
    end

    def fetch_city_costs(city_name, country_name)
      uri = URI("#{BASE_URL}/prices")
      uri.query = URI.encode_www_form(city_name: city_name, country_name: country_name)

      request = Net::HTTP::Get.new(uri)
      request['X-RapidAPI-Key'] = @api_key
      request['X-RapidAPI-Host'] = @api_host

      ssl_options = {
        use_ssl: true,
        open_timeout: 5,
        read_timeout: 10
      }
      ssl_options[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if @skip_ssl_verify

      begin
        response = Net::HTTP.start(uri.hostname, uri.port, **ssl_options) do |http|
          http.request(request)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise "TravelTables Client Error: Timeout - #{e.message}"
      rescue StandardError => e
        raise "TravelTables Client Error: #{e.message}"
      end

      case response
      when Net::HTTPSuccess
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise "TravelTables Client Error: JSON Parse Error - #{e.message}"
        end
      else
        # Handle 429 specifically
        if response.code == "429"
          retry_after = response['Retry-After']&.to_i
          raise RateLimitError.new(code: response.code, retry_after: retry_after, body: response.body)
        else
          raise "TravelTables API Error: #{response.code} #{response.message} - #{response.body}"
        end
      end
    end
  end
end
