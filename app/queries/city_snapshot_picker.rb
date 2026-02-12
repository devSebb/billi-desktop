# Picks the "display" snapshot for a city: latest traveltables, else latest estimated, else nil.
# Preloads :items to avoid N+1. Use consistently everywhere (profile, cards, etc.).
class CitySnapshotPicker
  def self.call(city)
    new(city).call
  end

  def initialize(city)
    @city = city
  end

  def call
    return nil unless @city

    snapshot = @city.price_snapshots
      .where(source: "traveltables")
      .order(collected_at: :desc)
      .limit(1)
      .includes(:items)
      .first

    snapshot ||= @city.price_snapshots
      .where(source: "estimated")
      .order(collected_at: :desc)
      .limit(1)
      .includes(:items)
      .first

    snapshot
  end
end
