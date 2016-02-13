module FilmHelper
  def backdrop_uri(film)
    return film.backdrop if film.backdrop
    image_path('default-backdrop.jpg')
  end

  def imdb_url(id)
    "http://www.imdb.com/title/#{id}"
  end

  def poster_uri(film)
    return film.poster if film.poster

    case film.name.split(':').first
    when 'Bolshoi Ballet' then image_path('default-bolshoi-ballet.jpg')
    when 'English National Opera' then image_path('default-english-national-opera.jpg')
    when 'Exhibition on Screen' then image_path('default-exhibition-on-screen.jpg')
    when 'Globe on Screen' then image_path('default-shakespeares-globe.jpg')
    when 'Met Opera' then image_path('default-met-opera.jpg')
    when 'National Theatre' then image_path('default-nt-live.jpg')
    when 'NT Live' then image_path('default-nt-live.jpg')
    when 'Royal Ballet' then image_path('default-royal-ballet.jpg')
    when 'Royal Opera House' then image_path('default-royal-opera-house.jpg')
    when 'Royal Shakespeare Company' then image_path('default-royal-shakespeare-company.jpg')
    when 'San Francisco Opera' then image_path('default-san-francisco-opera.jpg')
    else image_path('default-poster.jpg')
    end
  end

  def querify(name)
    name.downcase.gsub(/[^a-z0-9 ]/, '').tr(' ', '+')
  end

  def tmdb_url(id)
    "https://www.themoviedb.org/movie/#{id}"
  end
end
