class ScreeningsController < ApplicationController
  respond_to :json, :html

  before_filter :assign_cinema

  def index
    @screenings = ScreeningGrouper.new(@cinema.screenings)
  end

  private

  def assign_cinema
    @cinema = Cinema.find(params[:cinema_id])
  end
end
