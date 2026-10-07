class PerformancesController < ApplicationController
  allow_unauthenticated_access

  def index
    @cinema = Cinema.find_by!(public_id: params[:cinema_id])
    return redirect_to cinema_performances_path(@cinema, date: "today") unless params[:date]
    @date = listing_date
    @performances = @cinema.performances.publicly_visible.on(@date).includes(:film)
  rescue ArgumentError
    render plain: "Use YYYY-MM-DD, today or tomorrow", status: :bad_request
  end
end
