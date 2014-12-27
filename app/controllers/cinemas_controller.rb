class CinemasController < ApplicationController
  def index
    if near(params)
      @cinemas = Cinema.closest_to(latitude(params), longitude(params))
    else
      @cinemas = Cinema.all
    end
  end

  def show
    @cinema = Cinema.find(params[:id])
  end

  private

  def latitude(params)
    near(params).fetch(0, nil)
  end

  def longitude(params)
    near(params).fetch(1, nil)
  end

  def near(params)
    params[:near].present? ? params[:near].split(',').map(&:to_f) : nil
  end
end
