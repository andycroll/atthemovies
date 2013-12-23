class CinemasController < ApplicationController
  respond_to :json, :html

  def show
    @cinema = Cinema.find_by(url: params[:id])
  end
end
