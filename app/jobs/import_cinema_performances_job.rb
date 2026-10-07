class ImportCinemaPerformancesJob < ApplicationJob
  def perform(cinema)
    id = cinema.external_identifiers.find_by!(source: "picturehouse_venue").value
    Providers::Picturehouse.new.performances(id).each do |attributes|
      next if attributes[:starting_at] < Time.current
      import!(cinema, attributes)
    end
  end

  def import!(cinema, attributes)
    film = Film.resolve_title!(attributes.fetch(:name))
    Performance.transaction do
      identity = { film: film, dimension: attributes.fetch(:dimension).downcase, starting_at: attributes.fetch(:starting_at) }
      performance = cinema.performances.find_or_initialize_by(identity)
      performance.update!(variant: attributes.fetch(:variant), booking_url: attributes[:booking_url])
    end
  end
end
