# We should really be telling film to simply store the poster, but this is the
# easiest way to test things and be 'clean' about it.
class FilmPosterStorerJob < Job

  attr_reader :film_id

  def initialize(args)
    @film_id = args[:film_id]
  end

  def perform
    remove_poster
    store_new_poster
  end

  private

  # @note from https://github.com/carrierwaveuploader/carrierwave#removing-uploaded-files
  def remove_poster
    film.remove_poster!
    film.save
  end

  # @note from https://github.com/carrierwaveuploader/carrierwave#uploading-files-from-a-remote-location
  def store_new_poster
    film.remote_poster_url = film.poster_source_uri
    film.save
  end

  def film
    @film ||= Film.find(film_id)
  end
end
