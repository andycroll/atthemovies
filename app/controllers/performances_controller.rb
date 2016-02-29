class PerformancesController < ApplicationController
  before_action :redirect_to_today_unless_date_constrained
  before_action :assign_cinema
  before_action :assign_date

  def index
    @performances = @cinema.performances
                           .on(@date)
                           .order(starting_at: :asc)
                           .includes(:film)
  end

  private

  def assign_cinema
    @cinema = Cinema.find_by_url!(params[:cinema_id])
  end

  def assign_date
    @date = DateParser.new(params[:when]).to_date
  end

  def redirect_to_today_unless_date_constrained
    redirect_to dated_cinema_performances_path(params[:cinema_id], when: 'today') and return unless params[:when]
  end

  class DateParser
    def initialize(text)
      @text = text
    end

    def to_date
      case @text
      when 'today' then Date.today
      when 'tomorrow' then Date.tomorrow
      else Date.parse(@text)
      end
    end
  end
end
