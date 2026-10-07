module Operator
  class CinemasController < ApplicationController
    before_action { @cinema = Cinema.find_by!(public_id: params[:id]) }

    def edit
    end

    def update
      if @cinema.update(params.require(:cinema).permit(:name, :street_address, :extended_address, :locality, :region, :postal_code, :country, :country_code, :latitude, :longitude, :screenings_url))
        redirect_to cinema_path(@cinema, suffix: @cinema.suffix), notice: "Cinema saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
