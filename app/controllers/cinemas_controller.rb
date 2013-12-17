class CinemasController < ApplicationController
  def show
    @cinema = Cinema.find_by(url: params[:id])
  end
end
