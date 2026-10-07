class EnrichPendingFilmsJob < ApplicationJob
  def perform
    return unless ENV["TMDB_ACCESS_TOKEN"].present? || Rails.application.credentials.dig(:tmdb, :access_token).present?
    Film.where(enrichment_state: [ "pending", "failed" ]).find_each do |film|
      if film.external_identifiers.exists?(source: "tmdb_movie")
        EnrichFilmJob.perform_later(film)
      else
        SearchTmdbJob.perform_later(film)
      end
    end
  end
end
