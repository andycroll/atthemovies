# We should really be telling film to simply store the backdrop, but this is the
# easiest way to test things and be 'clean' about it.
class FilmBackdropStorerJob < Job

  attr_reader :film_id

  def initialize(args)
    @film_id = args[:film_id]
  end

  def perform
    remove_backdrop
    store_new_backdrop
  end

  private

  # @note from https://github.com/carrierwaveuploader/carrierwave#removing-uploaded-files
  def remove_backdrop
    film.remove_backdrop!
    film.save
  end

  # @note from https://github.com/carrierwaveuploader/carrierwave#uploading-files-from-a-remote-location
  def store_new_backdrop
    film.remote_backdrop_url = film.backdrop_source_uri
    film.save
  end

  def film
    @film ||= Film.find(film_id)
  end
end
