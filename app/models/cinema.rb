class Cinema < ApplicationRecord
  has_secure_token :public_id
  attr_readonly :public_id
  has_many :external_identifiers, as: :identifiable, dependent: :destroy
  has_many :performances, dependent: :destroy
  validates :name, :brand, presence: true
  validates :screenings_url, format: { with: %r{\Ahttps://[^\s/]+(?:/[^\s]*)?\z} }, allow_blank: true

  def to_param
    public_id
  end

  def suffix
    parts = [ name ]
    parts << locality unless locality.blank? || name.downcase.include?(locality.downcase)
    parts.join(" ").parameterize
  end

  def address
    [ street_address, extended_address, locality, region, postal_code, country ].compact_blank.join(", ")
  end

  def distance_from(latitude, longitude)
    return Float::INFINITY unless self.latitude && self.longitude
    radians = Math::PI / 180
    a = Math.sin((self.latitude.to_f - latitude) * radians / 2)**2 +
      Math.cos(latitude * radians) * Math.cos(self.latitude.to_f * radians) *
      Math.sin((self.longitude.to_f - longitude) * radians / 2)**2
    6371 * 2 * Math.asin(Math.sqrt(a.clamp(0, 1)))
  end
end
