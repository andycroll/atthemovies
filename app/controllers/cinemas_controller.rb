class CinemasController < ApplicationController
  respond_to :json, :html

  def index
    @cinemas = Cinema.all
  end

  def show
    @cinema = Cinema.find_by(url: params[:id])
  end
end
