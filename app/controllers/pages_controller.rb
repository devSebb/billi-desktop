class PagesController < ApplicationController
  def home
    redirect_to trips_path if user_signed_in?
  end
end

