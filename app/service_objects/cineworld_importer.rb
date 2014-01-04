class CineworldImporter
  def import_cinemas
    cinemas = CineworldUk::Cinema.all
    cinemas.each do |cinema|
      Delayed::Job.enqueue CinemaImporterJob.new(cinema.name, cinema.brand, cinema.id, cinema.address)
    end
  end
    end
  end
end
