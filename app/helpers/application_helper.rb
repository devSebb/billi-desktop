module ApplicationHelper
  # Display amount in user's display currency when possible. trip_currency is the source (e.g. trip.currency).
  # Falls back to trip currency if no rate or no current_user.
  def format_in_display_currency(amount, trip_currency = "USD")
    return number_to_currency(0) if amount.nil?
    return number_to_currency(amount) unless current_user&.display_currency.present?

    display_currency = current_user.display_currency
    trip_currency = (trip_currency || "USD").to_s.upcase
    return number_to_currency(amount) if display_currency.upcase == trip_currency

    converted = FxRates.convert(amount, trip_currency, display_currency)
    if converted
      number_to_currency(converted, unit: currency_symbol(display_currency))
    else
      number_to_currency(amount) + " (#{trip_currency})"
    end
  end

  def currency_symbol(code)
    { "USD" => "$", "EUR" => "€", "GBP" => "£", "BRL" => "R$" }.fetch(code.to_s.upcase, code.to_s + " ")
  end

  # Returns Unsplash image URL for a city (same source as trip cards). Cached per city to avoid API hammering.
  def city_image_url(city)
    return nil unless city&.name.present?
    return nil unless ENV["UNSPLASH_ACCESS_KEY"].present?

    cache_key = "city_image_url/#{city.id}/#{city.name.parameterize}"
    Rails.cache.fetch(cache_key, expires_in: 7.days) do
      photos = Unsplash::Photo.search(city.name)
      photos.any? ? photos.first.urls.regular : nil
    end
  rescue StandardError => e
    Rails.logger.error "city_image_url(#{city.name}): #{e.message}"
    nil
  end

  def user_avatar(user, classes: "w-10 h-10 text-sm")
    if user.avatar.attached?
      image_tag user.avatar.variant(resize_to_fill: [200, 200]), class: "#{classes} rounded-full object-cover"
    else
      content_tag(:div, class: "#{classes} rounded-full bg-brand-charcoal flex items-center justify-center text-white font-medium") do
        (user.name || user.email).first.upcase
      end
    end
  end
end
