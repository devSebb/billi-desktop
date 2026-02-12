class PagesController < ApplicationController
  def home
    return redirect_to(trips_path) if user_signed_in?

    @featured_snapshots = FeaturedCitySnapshots.call(limit: 10)
    @city_count = City.count
  end
end

