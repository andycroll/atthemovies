module EverymanUk
  # A single screening of a film on the Everyman website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [String] :language (nil) audio language, e.g. 'Korean'
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of listings days, from one
    # schedule request for the whole range and one request per 50 films.
    # @param [String] cinema_id id of the cinema, e.g. 'X0712'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<EverymanUk::Performance>]
    def self.at(
      cinema_id,
      from: TZInfo::Timezone.get('Europe/London').now.to_date,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      api = EverymanUk::Internal::ApiResponse.new
      schedule = api.schedule(cinema.id, time_zone: cinema.time_zone, from: from, to: to)
      movies = api.movies(schedule.keys).to_h { |movie| [movie.fetch('id').to_s, movie] }

      performances = schedule.flat_map do |movie_id, days|
        title = movies.dig(movie_id.to_s, 'title')
        next [] unless title

        days.values.flatten.map do |showtime|
          parsed = EverymanUk::Internal::Boxoffice::Showtime.new(showtime, time_zone: cinema.time_zone)
          new(attributes(parsed, title).merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
      end
      performances.sort_by(&:starting_at)
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (35mm, arts, baby, kids, subtitled ...)
    #   @return <Array[String]>

    # private

    # Release dates are UK releases, so re-releases would get the wrong year;
    # only a year in the title counts.
    def self.attributes(showtime, title)
      starting_at = showtime.starting_at
      {
        booking_url: showtime.booking_url,
        dimension: showtime.dimension,
        festival: Cinebase::Festival.from_title(title, year: starting_at.year),
        film_name: EverymanUk::Internal::TitleSanitizer.new(title).sanitized,
        film_year: Cinebase::TitleSanitizer.film_year(title),
        language: showtime.language || title[/\((#{Cinebase::TitleSanitizer::LANGUAGES.join('|')})\)/i, 1],
        starting_at: starting_at,
        variant: showtime.variant
      }
    end
    private_class_method :attributes
  end
end
