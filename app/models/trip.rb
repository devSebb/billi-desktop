class Trip < ApplicationRecord
  belongs_to :user
  has_one :trip_preference, dependent: :destroy
  has_one :trip_budget, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :trip_participants, dependent: :destroy

  validates :name, presence: true
  validates :destination_city, presence: true
  validates :destination_country, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :travelers_count, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :trip_preference
  
  after_create :create_default_preference
  
  before_save :set_image_url, if: :should_generate_image?

  def duration_nights
    (end_date - start_date).to_i
  end

  private

  def should_generate_image?
    image_url.blank? || will_save_change_to_destination_city?
  end

  def set_image_url
    return unless destination_city.present?
    return unless ENV["UNSPLASH_ACCESS_KEY"].present?

    begin
      photos = Unsplash::Photo.search(destination_city)
      if photos.any?
        self.image_url = photos.first.urls.regular
      end
    rescue => e
      Rails.logger.error "Unsplash Error: #{e.message}"
    end
  end

  def create_default_preference
    create_trip_preference unless trip_preference
  end
end
