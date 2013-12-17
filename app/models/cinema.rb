class Cinema < ActiveRecord::Base
  acts_as_url :name

  geocoded_by :address_str
  after_validation :geocode

  # A simple string version of the cinema address
  # @return [String]
  def address_str
    "#{street_address}, #{locality} #{postal_code}"
  end
end
