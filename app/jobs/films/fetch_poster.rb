module Films
  # take the original poster uri from a film and convert it into a smaller local
  # version stored on our own cdn
  class FetchPoster < ActiveJob::Base
    WIDTH = 400
    HEIGHT = 600

    def perform(film)
      @film = film
      return if @film.poster_source_uri.nil?

      remote_url = store_new_poster
      @film.update_attributes(poster: remote_url)
    end

    private

    # in the format posters/birdman-2014/400x600-TIMESTAMP
    def file_name
      @file_name ||= "posters/#{film_path}/#{WIDTH}x#{HEIGHT}-#{time}"
    end

    def film_path
      "#{@film.name.to_url}-#{@film.year}"
    end

    def store_options
      {
        width:     WIDTH,
        height:    HEIGHT,
        url:       @film.poster_source_uri,
        file_name: file_name
      }
    end

    def store_new_poster
      ImageUploader.new(store_options).store
    end

    def time
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
