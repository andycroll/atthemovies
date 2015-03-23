module FilmHelper
  def tmdb_url(id)
    "https://www.themoviedb.org/movie/#{id}"
  end

  def imdb_url(id)
    "http://www.imdb.com/title/#{id}"
  end
end
