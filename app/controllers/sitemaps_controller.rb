class SitemapsController < ApplicationController
  allow_unauthenticated_access

  def show
    @cinemas = Cinema.order(:name)
    @films = Film.showing
  end
end
