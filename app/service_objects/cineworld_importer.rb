class CineworldImporter
  def import_cinemas
    cinemas = CineworldUk::Cinema.all
    cinemas.each do |cinema|
      Delayed::Job.enqueue CinemaImporterJob.new(cinema.name, cinema.brand, cinema.id, cinema.address)
    end
  end

  def import_screenings(cinema_id)
    cinema = Cinema.find(cinema_id)

    cineworld_cinema = CineworldUk::Cinema.find(cinema.brand_id)
    cineworld_cinema.screenings.each do |s|
      Delayed::Job.enqueue ScreeningImporterJob.new(cinema.id, s.film_name, s.when, s.variant)
    end
  end
end
