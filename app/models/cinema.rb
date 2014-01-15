class Cinema < ActiveRecord::Base
  has_many :screenings

  acts_as_url :name

  geocoded_by :address_str
  after_validation :geocode, if: :address_str

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
    %w(street_address extended_address locality region postal_code country).map(&:to_sym).each do |attr|
      send(:"#{attr}=", address[attr]) if address[attr]
    end
    save
  end
end
