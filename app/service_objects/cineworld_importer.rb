class CineworldImporter
  def import_cinemas
    cinemas.each do |cinema|
      CinemaImporterJob.enqueue(
        name: cinema.full_name,
        brand: cinema.brand,
        brand_identifier: cinema.id,
        address: cinema.address
      )
    end
  end

  def import_screenings
    Cinema.where(brand: 'Cineworld').each do |cinema|
      import_screenings_for_cinema(cinema)
    end
  end

  def import_screenings_for_cinema(cinema)
    cineworld_cinema(cinema.brand_identifier).screenings.each do |s|
      ScreeningImporterJob.enqueue(
        cinema_id: cinema.id,
        film_name: s.film_name,
        showing_at: s.when,
        variant: s.variant
      )
    end
  end

  private

  def cinemas
    CineworldUk::Cinema.all
  end

  def cineworld_cinema(brand_identifier)
    CineworldUk::Cinema.find(brand_identifier.to_s)
  end
end
