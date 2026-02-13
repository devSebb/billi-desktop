# frozen_string_literal: true

# Lightweight health check for Render/load balancers. GET /up returns 200 if app and DB are reachable.
class HealthController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render plain: "ok", status: :ok
  rescue StandardError
    render plain: "unhealthy", status: :service_unavailable
  end
end
