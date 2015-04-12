module FilmHelper
  def imdb_url(id)
    "http://www.imdb.com/title/#{id}"
  end

  def querify(name)
    name.downcase.gsub(/[^a-z0-9 ]/, '').gsub(' ', '+')
  end

  def tmdb_url(id)
    "https://www.themoviedb.org/movie/#{id}"
  end
end
