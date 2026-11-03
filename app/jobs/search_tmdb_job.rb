class SearchTmdbJob < ApplicationJob
  LEADING_ARTICLE = /\A(?:a|an) /

  def perform(film)
    title = film.name
    state = film.enrichment_state
    client = TmdbClient.new
    results = film.year ? client.search(title, year: film.year) : []
    results = client.search(title) if results.empty?
    film.with_lock do
      return if film.name != title || film.enrichment_state != state
      film.tmdb_candidates.destroy_all
      results.each do |candidate|
        film.tmdb_candidates.create!(tmdb_id: candidate.fetch("id").to_s, name: candidate.fetch("title"), year: candidate["release_date"].to_s.first(4).presence)
      end
      film.update!(enrichment_state: results.empty? ? "no_match" : "candidates")
      match = matching_result(results, film)
      if match
        linked = film.link_tmdb!(match.fetch("id").to_s)
        EnrichFilmJob.perform_later(film) if linked == film
      end
    end
  rescue HttpClient::Error, JSON::ParserError, KeyError, Timeout::Error, SocketError
    film.update!(enrichment_state: "failed")
    raise
  end

  private
    # The one result titled as the film, or else, in the film's year, the one
    # whose title the cinema extended with a subtitle
    def matching_result(results, film)
      name = comparable(film.name)
      exact = results.select { |result| result.values_at("title", "original_title").compact.any? { |title| comparable(title) == name } }
      if exact.any?
        exact.sole if exact.one?
      elsif film.year
        subtitled = results.select { |result| name.start_with?("#{comparable(result.fetch("title"))} ") && result["release_date"].to_s.start_with?(film.year.to_s) }
        subtitled.sole if subtitled.one?
      end
    end

    def comparable(title)
      FilmAlias.normalize(title).sub(LEADING_ARTICLE, "")
    end
end
