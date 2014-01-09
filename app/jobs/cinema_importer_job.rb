class CinemaImporterJob < Struct.new(:name, :brand, :brand_identifier, :address)
  def perform
    cinema = Cinema.find_or_initialize_by(
      name:             name,
      brand:            brand,
      brand_identifier: brand_identifier.to_s
    )
    cinema.update_address(address)
  end
end
