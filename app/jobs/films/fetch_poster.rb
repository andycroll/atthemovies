# frozen_string_literal: true
require_relative '../concerns/film_image_fetcher'

module Films
  # take the original poster uri from a film and convert it into a smaller local
  # version stored on our own cdn
  class FetchPoster < ActiveJob::Base
    include FilmImageFetcher

    def perform(film)
      @film = film
      return if @film.poster_source_uri.nil?

      remote_url = store_new_poster
      @film.update_attributes(poster: remote_url)
    end

    private

    # in the format posters/birdman-2014/400x600-TIMESTAMP
    def store_new_poster
      ImageUploader.new(file_name: "posters/#{film_path}/400x600-#{time}",
                        width: 400,
                        height: 600,
                        url: @film.poster_source_uri).store
    end
  end
end
