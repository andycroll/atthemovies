class Performance < ApplicationRecord
  belongs_to :cinema
  belongs_to :film, counter_cache: true
  before_validation do
    self.dimension = dimension.to_s.downcase
    self.variant = variant.to_s.downcase
  end
  validates :dimension, :variant, :starting_at, presence: true
  validates :booking_url, format: { with: %r{\Ahttps://[^\s/]+(?:/[^\s]*)?\z} }, allow_blank: true
  scope :upcoming, -> { where(starting_at: Time.current..).order(:starting_at) }
  scope :publicly_visible, -> { joins(:film).merge(Film.visible) }

  def self.on(date)
    beginning = date.in_time_zone.beginning_of_day
    beginning = [ beginning, Time.current ].max if date == Date.current
    where(starting_at: beginning...date.in_time_zone.tomorrow.beginning_of_day).order(:starting_at)
  end
end
