module ApplicationHelper
  # Display amount in user's display currency when possible. source_currency is the stored currency (now always USD).
  # Defaults to USD display when no user preference.
  def format_in_display_currency(amount, source_currency = "USD")
    return number_to_currency(0, unit: "$") if amount.nil?

    display_currency = current_user&.display_currency.presence || "USD"
    source_currency = (source_currency || "USD").to_s.upcase
    display_currency = display_currency.to_s.upcase

    return number_to_currency(amount, unit: currency_symbol(display_currency)) if display_currency == source_currency

    converted = FxRates.convert(amount, source_currency, display_currency)
    if converted
      number_to_currency(converted, unit: currency_symbol(display_currency))
    else
      number_to_currency(amount, unit: currency_symbol(source_currency)) + " (#{source_currency})"
    end
  end

  def currency_symbol(code)
    { "USD" => "$", "EUR" => "€", "GBP" => "£", "BRL" => "R$", "CHF" => "CHF " }.fetch(code.to_s.upcase, code.to_s + " ")
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
