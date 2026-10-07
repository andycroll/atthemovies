class FilmsController < ApplicationController
  allow_unauthenticated_access

  def index
    @films = Film.showing.with_attached_poster
    if params[:q].present?
      query = "%#{Film.sanitize_sql_like(params[:q].strip)}%"
      @films = Film.visible.where("name LIKE ?", query).with_attached_poster.order(:name)
    end
  end

  def show
    @film = Film.visible.find_by!(public_id: params[:id])
    @canonical_url = film_url(@film, suffix: @film.suffix)
    if params[:suffix] != @film.suffix
      redirect_to @canonical_url, status: :moved_permanently
    else
      @performances = @film.performances.upcoming.includes(:cinema)
    end
  end
end
