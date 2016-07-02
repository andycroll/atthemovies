class Api::V1::FilmsController < ApplicationController
  def index
    @films = Film.whats_on
    render json: @films
  end
end
