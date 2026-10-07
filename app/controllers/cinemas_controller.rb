class CinemasController < ApplicationController
  allow_unauthenticated_access

  def index
    @cinemas = Cinema.order(:name).to_a
    if params[:near].present?
      coordinates = params[:near].split(",").map { |value| Float(value) }
      raise ArgumentError unless coordinates.length == 2 && coordinates[0].between?(-90, 90) && coordinates[1].between?(-180, 180)
      @cinemas.sort_by! { |cinema| cinema.distance_from(*coordinates) }
    end
  rescue ArgumentError
    render plain: "Use near=LATITUDE,LONGITUDE", status: :bad_request
  end

  def show
    @cinema = Cinema.find_by!(public_id: params[:id])
    @canonical_url = cinema_url(@cinema, suffix: @cinema.suffix)
    redirect_to @canonical_url, status: :moved_permanently if params[:suffix] != @cinema.suffix
  end
end
