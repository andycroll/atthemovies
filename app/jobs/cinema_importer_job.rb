class CinemaImporterJob < Struct.new(:name, :brand, :brand_id, :address)
  def perform
    cinema = Cinema.find_or_initialize_by(
      name:     name,
      brand:    brand,
      brand_id: brand_id
    )
    cinema.update_address(address)
  end
end
