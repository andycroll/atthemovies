module Performances
  # creates performances asynchonously from passed data
  class Import < ActiveJob::Base
    def perform(args)
      @args = args

      @cinema     = Cinema.find(args[:cinema_id])
      @film       = Film.find_or_create_by_name(args[:film_name])

      existing_or_new_performance.update_variant!(@args[:variant])
    end

    private

    def existing_or_new_performance
      @cinema.performances.find_or_initialize_by(
        film:       @film,
        dimension:  @args[:dimension],
        starting_at: @args[:starting_at]
      )
    end
  end
end
