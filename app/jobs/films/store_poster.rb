module Films
  class StorePoster < ActiveJob::Base
    WIDTH = 400
    HEIGHT = 600

    def perform(film)
      @film = film
      return unless @film.hydrated? && @film.poster.nil?

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

    def store_new_poster
      opts = { width: WIDTH, height: HEIGHT, url: @film.poster_source_uri, file_name: file_name }
      ImageUploader.new(opts).store
    end

    def time
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
