class CinemaImporterJob < Struct.new(:name, :brand, :address)
  def perform
    cinema = Cinema.find_or_create_by(
      name: name,
      brand: brand
    )
    cinema.update_attributes(
      street_address:   address[:street_address],
      extended_address: address[:extended_address],
      locality:         address[:locality],
      region:           address[:region],
      postal_code:      address[:postal_code],
      country:          address[:country]
    )
  end
end
