# frozen_string_literal: true
require_relative '../concerns/film_image_fetcher'

module Films
  # take the original backdrop uri from a film and convert it into a smaller
  # local version stored on our own cdn
  class FetchBackdrop < ActiveJob::Base
    include FilmImageFetcher

    def perform(film)
      @film = film
      return if @film.backdrop_source_uri.nil?

      remote_url = store_new_backdrop
      @film.update_attributes(backdrop: remote_url)
    end

    private

    # in the format backdrops/birdman-2014/400x600-TIMESTAMP
    def store_new_backdrop
      ImageUploader.new(file_name: "backdrops/#{film_path}/800x450-#{time}",
                        width: 800,
                        height: 450,
                        url: @film.backdrop_source_uri).store
    end
  end
end
