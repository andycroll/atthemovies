class ImportChainPerformancesJob < ApplicationJob
  retry_on Cinebase::Vista::AuthenticationError, wait: :polynomially_longer, attempts: 5

  def perform(cinema, key)
    chain = Chain.new(key)
    id = cinema.external_identifiers.find_by!(source: chain.source).value
    performances = chain.authenticated { chain.performances(id) }
    performances.each do |performance|
      next if performance.starting_at < Time.current
      import!(cinema, name: performance.film_name, year: performance.film_year, starting_at: performance.starting_at,
        dimension: performance.dimension, variant: performance.variant.join(", ").presence || "standard",
        booking_url: performance.booking_url)
    end
  end

  def import!(cinema, attributes)
    film = Film.resolve_title!(attributes.fetch(:name), year: attributes[:year])
    Performance.transaction do
      identity = { film: film, dimension: attributes.fetch(:dimension).downcase, starting_at: attributes.fetch(:starting_at) }
      performance = cinema.performances.find_or_initialize_by(identity)
      performance.update!(variant: attributes.fetch(:variant), booking_url: attributes[:booking_url])
    end
  end
end
