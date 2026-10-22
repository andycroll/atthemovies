class ImportCineworldPerformancesJob < ImportCinemaPerformancesJob
  retry_on CineworldUk::AuthenticationError, wait: :polynomially_longer, attempts: 5

  def perform(cinema)
    id = cinema.external_identifiers.find_by!(source: "cineworld_venue").value
    CineworldUk.acquire_token!
    response = HttpClient.new.request(
      "https://digital-api.cineworld.co.uk/ocapi/v1/film-screening-dates?siteIds=#{id.rjust(3, '0')}",
      headers: { "Authorization" => "Bearer #{CineworldUk.token}", "Connect-Region-Code" => "GB" })
    dates = JSON.parse(response).fetch("filmScreeningDates").map { |entry| Date.iso8601(entry.fetch("businessDate")) }.uniq.sort
    dates.each do |date|
      CineworldUk::Performance.at(id, from: date, to: date).each do |performance|
        next if performance.starting_at < Time.current
        import!(cinema, name: performance.film_name, year: performance.film_year, starting_at: performance.starting_at,
          dimension: performance.dimension, variant: performance.variant.presence&.join(", ") || "standard",
          booking_url: performance.booking_url)
      end
    end
  end
end
