class SearchTmdbJob < ApplicationJob
  def perform(film)
    title = film.name
    state = film.enrichment_state
    results = TmdbClient.new.search(title)
    film.with_lock do
      return if film.name != title || film.enrichment_state != state
      film.tmdb_candidates.destroy_all
      results.each do |candidate|
        film.tmdb_candidates.create!(tmdb_id: candidate.fetch("id").to_s, name: candidate.fetch("title"), year: candidate["release_date"].to_s.first(4).presence)
      end
      film.update!(enrichment_state: results.empty? ? "no_match" : "candidates")
      if results.one? && FilmAlias.normalize(results.first.fetch("title")) == FilmAlias.normalize(film.name)
        identifier = film.external_identifiers.find_or_initialize_by(source: "tmdb_movie")
        identifier.update!(value: results.first.fetch("id").to_s)
        EnrichFilmJob.perform_later(film)
      end
    end
  rescue HttpClient::Error, JSON::ParserError, KeyError, Timeout::Error, SocketError
    film.update!(enrichment_state: "failed")
    raise
  end
end
