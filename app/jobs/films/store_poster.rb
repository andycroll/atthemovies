module Films
  class StorePoster < ActiveJob::Base
    def perform(film)
      # film.remove_poster!
      # film.remote_poster_url = film.poster_source_uri
      film.save
    end
  end
end
