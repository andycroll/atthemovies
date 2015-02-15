class CinemasController < ApplicationController
  def index
    if near_params
      @cinemas = Cinema.closest_to(latitude_param, longitude_param)
    else
      @cinemas = Cinema.all
    end
  end

  def show
    @cinema = Cinema.find_by_url!(params[:id])
  end

  private

  def latitude_param
    near_params.fetch(0, nil)
  end

  def longitude_param
    near_params.fetch(1, nil)
  end

  def near_params
    params[:near].present? ? params[:near].split(',').map(&:to_f) : nil
  end
end
