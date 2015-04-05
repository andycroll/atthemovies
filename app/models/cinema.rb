class Cinema < ActiveRecord::Base
  ADDRESS_FIELDS = %i(street_address extended_address locality region
                      postal_code country)

  has_many :screenings, -> { ordered }

  acts_as_url :name

  geocoded_by :address_str
  after_validation :geocode, if: :address_changed?

  # Sort cinemas by nearest to a passed lat, lng
  # @return [ActiveRecord::Relation<Cinema>]
  def self.closest_to(lat, lng)
    near([lat, lng], 1_000)
  end

  # A simple string version of the cinema address
  # @return [String]
  def address_str
    return nil unless street_address && locality
    "#{street_address}, #{locality} #{postal_code}"
  end

  # use url for routing
  # @return [String]
  def to_param
    url
  end

  # Updates address fields for a cinema
  # @param [Hash]
  # @return [Boolean] the updated object
  def update_address(address)
    ADDRESS_FIELDS.each do |attr|
      send(:"#{attr}=", address[attr]) if address[attr]
    end
    save
  end

  private

  def address_changed?
    address_str &&
      street_address_changed? || locality_changed? || postal_code_changed?
  end
end
