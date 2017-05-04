# frozen_string_literal: true
module FilmImageFetcher
  extend ActiveSupport::Concern

  private

  def film_path
    "#{@film.name.to_url}-#{@film.year}"
  end

  def time
    Time.now.strftime('%Y%m%d%H%M%S')
  end
end
