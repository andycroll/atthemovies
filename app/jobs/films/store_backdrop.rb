module Films
  class StoreBackdrop < ActiveJob::Base
    def perform(film)
      # film.remove_backdrop!
      # film.remote_backdrop_url = film.backdrop_source_uri
      film.save
    end
  end
end
