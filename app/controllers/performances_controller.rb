class PerformancesController < ApplicationController
  def index
    @cinema = Cinema.find_by_url!(params[:cinema_id])
    @performances = PerformanceGrouper.new(@cinema.performances.includes(:film))
  end
end
