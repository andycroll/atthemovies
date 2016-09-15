module Api
  module V1
    module Films
      class PerformancesController < ApplicationController
        def index
          @film = Film.find(params[:film_id])
          @performances = @film.performances.includes(:cinema).on(date)
          render json: @performances
        end

        private

        def date
          raise ActionController::ParameterMissing, 'Bad date format' unless !!(params[:date] || '').match(/2\d{3}[01]\d[0123]\d/)
          Date.parse(params[:date])
        end
      end
    end
  end
end
