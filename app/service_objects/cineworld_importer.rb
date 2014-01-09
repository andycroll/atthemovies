class CineworldImporter
  def import_cinemas
    cinemas = CineworldUk::Cinema.all
    cinemas.each do |cinema|
      Delayed::Job.enqueue CinemaImporterJob.new(cinema.name, cinema.brand, cinema.id, cinema.address)
    end
  end

  def import_screenings
    Cinema.where(brand: 'Cineworld').each do |cinema|
      import_screenings_for_cinema(cinema)
    end
  end

  def import_screenings_for_cinema(cinema)
    cineworld_cinema = CineworldUk::Cinema.find(cinema.brand_identifier.to_s)
    cineworld_cinema.screenings.each do |s|
      Delayed::Job.enqueue ScreeningImporterJob.new(cinema.id, s.film_name, s.when, s.variant)
    end
  end
end
