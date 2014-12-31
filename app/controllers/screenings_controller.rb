class ScreeningsController < ApplicationController
  before_filter :assign_cinema

  def index
    @screenings = ScreeningGrouper.new(@cinema.screenings.includes(:film))
  end

  private

  def assign_cinema
    @cinema = Cinema.find_by_url(params[:cinema_id])
  end
end
