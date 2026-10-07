class EnrichFilmJob < ApplicationJob
  def perform(film)
    id = film.external_identifiers.find_by!(source: "tmdb_movie").value
    client = TmdbClient.new
    details = client.movie(id)
    film.with_lock do
      return if film.enrichment_state == "no_match" || film.external_identifiers.find_by(source: "tmdb_movie")&.value != id
      %w[poster backdrop].each do |kind|
        path = details["#{kind}_path"]
        film.public_send("#{kind}_source_url=", path.present? ? "https://image.tmdb.org/t/p/original#{path}" : nil)
      end
      film.update!(year: details["release_date"].to_s.first(4).presence, runtime: details["runtime"], tagline: details["tagline"], overview: details["overview"], enrichment_state: "matched")
      if details["imdb_id"].present?
        identifier = film.external_identifiers.find_or_initialize_by(source: "imdb_title")
        identifier.update!(value: details["imdb_id"])
      end
      StoreFilmImagesJob.perform_later(film)
    end
  rescue HttpClient::Error, JSON::ParserError, KeyError, Timeout::Error, SocketError
    film.update!(enrichment_state: "failed")
    raise
  end
end
