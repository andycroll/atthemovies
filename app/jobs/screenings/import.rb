module Screenings
  # creates screenings asynchonously from passed data
  class Import < ActiveJob::Base
    def perform(args)
      @args = args

      @cinema     = Cinema.find(args[:cinema_id])
      @film       = Film.find_or_create_by_name(args[:film_name])

      existing_or_new_screening.update_variant!(variant)
    end

    private

    def existing_or_new_screening
      @cinema.screenings.find_or_initialize_by(
        film:       @film,
        dimension:  @args[:dimension],
        showing_at: @args[:showing_at]
      )
    end

    def variant
      if @args[:variant].is_a?(Array)
        @args[:variant] * ' '
      else
        @args[:variant]
      end
    end
  end
end
