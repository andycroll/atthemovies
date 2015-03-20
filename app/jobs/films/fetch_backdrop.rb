module Films
  # take the original backdrop uri from a film and convert it into a smaller
  # local version stored on our own cdn
  class FetchBackdrop < ActiveJob::Base
    WIDTH = 800
    HEIGHT = 450

    def perform(film)
      @film = film
      return if @film.backdrop_source_uri.nil?

      remote_url = store_new_backdrop
      @film.update_attributes(backdrop: remote_url)
    end

    private

    # in the format backdrops/birdman-2014/400x600-TIMESTAMP
    def file_name
      @file_name ||= "backdrops/#{film_path}/#{WIDTH}x#{HEIGHT}-#{time}"
    end

    def film_path
      "#{@film.name.to_url}-#{@film.year}"
    end

    def store_options
      {
        width:     WIDTH,
        height:    HEIGHT,
        url:       @film.backdrop_source_uri,
        file_name: file_name
      }
    end

    def store_new_backdrop
      ImageUploader.new(store_options).store
    end

    def time
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
