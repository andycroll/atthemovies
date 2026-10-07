module Api
  class ListingsController < ApplicationController
    allow_unauthenticated_access
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Not found" }, status: :not_found
    end
    rescue_from ArgumentError do |error|
      render json: { error: error.message }, status: :bad_request
    end

    def cinemas
      render json: Cinema.order(:name).includes(:external_identifiers).map { |record| cinema_json(record) }
    end

    def cinema
      render json: cinema_json(Cinema.find_by!(public_id: params[:id]))
    end

    def films
      render json: Film.showing.includes(:external_identifiers).with_attached_poster.with_attached_backdrop.map { |record| film_json(record) }
    end

    def film
      render json: film_json(Film.visible.find_by!(public_id: params[:id]))
    end

    def cinema_performances
      render_performances(Cinema.find_by!(public_id: params[:id]).performances.publicly_visible)
    end

    def film_performances
      render_performances(Film.visible.find_by!(public_id: params[:id]).performances)
    end

    def film_cinemas
      film = Film.visible.find_by!(public_id: params[:id])
      render json: Cinema.where(id: film.performances.upcoming.select(:cinema_id)).includes(:external_identifiers).map { |record| cinema_json(record) }
    end

    private
      def cinema_json(record)
        record.attributes.slice("name", "brand", "street_address", "extended_address", "locality", "region", "postal_code", "country", "country_code", "latitude", "longitude", "screenings_url").merge(id: record.public_id, url: cinema_url(record, suffix: record.suffix), external_ids: record.external_identifiers.to_h { |identifier| [ identifier.source, identifier.value ] })
      end

      def film_json(record)
        record.attributes.slice("name", "year", "runtime", "tagline", "overview", "event", "performances_count").merge(
          id: record.public_id,
          url: film_url(record, suffix: record.suffix),
          poster_url: record.poster.attached? ? url_for(record.poster) : nil,
          backdrop_url: record.backdrop.attached? ? url_for(record.backdrop) : nil,
          external_ids: record.external_identifiers.to_h { |identifier| [ identifier.source.delete_suffix("_title").delete_suffix("_movie"), identifier.value ] }
        )
      end

      def render_performances(scope)
        render json: scope.on(listing_date).includes(:cinema, :film).map { |record|
          { cinema_id: record.cinema.public_id, film_id: record.film.public_id, starting_at: record.starting_at.iso8601, dimension: record.dimension, variant: record.variant, booking_url: record.booking_url }
        }
      end
  end
end
