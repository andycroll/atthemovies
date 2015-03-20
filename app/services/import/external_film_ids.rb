module Import
  class ExternalFilmIds
    def perform
      Film.no_tmdb_details.each do |film|
        Films::FetchExternalIds.perform_later(film)
      end
    end
  end
end
