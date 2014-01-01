class CineworldImporter
  def initialize
  end

  def import
    cinemas = CineworldUk::Cinema.all
    cinemas.each do |cinema|
      Delayed::Job.enqueue CinemaImporterJob.new(cinema.name, cinema.brand, cinema.address)
    end
  end
end
