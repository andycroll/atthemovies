module EverymanUk
  # A single screening of a film on the Everyman website
  class Performance < Cinebase::Boxoffice::Performance
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

    # @!method self.at(cinema_id, from: Date.today, to: from + 13)
    #   Performances within an inclusive range of listings days, from one
    #   schedule request for the whole range and one request per 50 films.
    #   @param [String] cinema_id id of the cinema, e.g. 'X0712'
    #   @param [Date] from first date (defaults to today in London)
    #   @param [Date] to last date (defaults to 13 days after from)
    #   @return [Array<EverymanUk::Performance>]

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (35mm, arts, baby, kids, subtitled ...)
    #   @return <Array[String]>

    # @api private
    def self.cinema_class
      Cinema
    end

    # @api private
    def self.title_sanitizer
      Internal::TitleSanitizer
    end
  end
end
