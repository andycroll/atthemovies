class Api::V1::PerformancesController < ApplicationController
  def index
    @cinema = Cinema.find(params[:cinema_id])
    @performances = @cinema.performances.on(date)
    render json: @performances
  end

  private

  def date
    raise StandardError, 'Bad date format' unless !!(params[:date] || '').match(/2\d{3}[01]\d[0123]\d/)
    Date.parse(params[:date])
  end
end
