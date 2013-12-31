class CinemaImporterJob < Struct.new(:name, :brand, :address)
  def perform
    cinema = Cinema.find_or_create_by(
      name: name,
      brand: brand
    )
    cinema.update_address(address)
  end
end
