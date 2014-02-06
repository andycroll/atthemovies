class CinemasController < ApplicationController
  respond_to :json, :html

  def index
    @cinemas = Cinema.all
  end

  def show
    @cinema = Cinema.find(params[:id])
  end
end
