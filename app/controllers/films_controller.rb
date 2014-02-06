class FilmsController < ApplicationController
  respond_to :json, :html

  def index
    @films = Film.whats_on
  end

  def show
    @film = Film.find(params[:id])
  end
end
