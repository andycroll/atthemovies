class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @films = Film.showing.with_attached_poster.limit(6)
    @cinema_count = Cinema.count
  end
end
