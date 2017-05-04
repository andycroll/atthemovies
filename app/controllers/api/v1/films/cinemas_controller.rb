# frozen_string_literal: true
module Api
  module V1
    module Films
      class CinemasController < ApplicationController
        def index
          ids = Performance.where(film_id: params[:film_id])
                           .pluck(:cinema_id)
                           .uniq
          @cinemas = Cinema.find(ids)

          render json: @cinemas
        end
      end
    end
  end
end
