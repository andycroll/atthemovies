# frozen_string_literal: true
class CinemasController < ApplicationController
  before_action :http_basic_auth, only: [:edit, :update]
  before_action :assign_cinema_by_url, except: [:index]

  def edit
  end

  def index
    @cinemas = if near_params
                 Cinema.closest_to(latitude_param, longitude_param)
               else
                 Cinema.all
               end
  end

  def show
  end

  def update
    @cinema.update_attributes(cinema_attributes)
    redirect_to cinemas_path
  end

  private

  def assign_cinema_by_url
    @cinema = Cinema.find_by_url!(params[:id])
  end

  def cinema_attributes
    params.require(:cinema).permit(*(Cinema::ADDRESS_FIELDS + [:name]))
  end

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
