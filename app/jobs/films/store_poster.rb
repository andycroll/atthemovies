module Films
  class StorePoster < Job
    attr_reader :film_id

    def initialize(args)
      @film_id = args[:film_id]
    end

    def perform
      remove_poster
      store_new_poster
    end

    private

    def remove_poster
      # film.remove_poster!
      film.save
    end

    def store_new_poster
      # film.remote_poster_url = film.poster_source_uri
      film.save
    end

    def film
      @film ||= Film.find(film_id)
    end
  end
end
