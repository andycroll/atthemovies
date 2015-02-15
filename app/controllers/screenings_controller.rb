class ScreeningsController < ApplicationController
  def index
    @cinema = Cinema.find_by_url!(params[:cinema_id])
    @screenings = ScreeningGrouper.new(@cinema.screenings.includes(:film))
  end
end
