module EverymanUk
  # The object representing a cinema on the Everyman website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the Boxoffice id of the cinema, e.g. 'X0712'

    # Worker processes outlive a day's listings, so refetch the theatre list
    CACHE_SECONDS = 3600

    # Constructor
    # @param [String] id the cinema id, e.g. 'X0712' or 'x0712'
    # @return [EverymanUk::Cinema]
    def initialize(id)
      @id = id.to_s.upcase
    end

    # Return basic cinema information for all open UK cinemas
    # @return [Array<EverymanUk::Cinema>]
    # @example
    #   EverymanUk::Cinema.all
    #   #=> [<EverymanUk::Cinema>, <EverymanUk::Cinema>, ...]
    def self.all
      theaters_hash.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = EverymanUk::Cinema.new('X0712')
    #   cinema.adr
    #   #=> {
    #         street_address:   '96-98 Baker Street',
    #         extended_address: nil,
    #         locality:         'London',
    #         region:           nil,
    #         postal_code:      'W1U 6TJ',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      location = theater.dig('practicalInfo', 'location') || {}
      {
        street_address:   location['address'],
        extended_address: nil,
        locality:         location['city'],
        region:           nil,
        postal_code:      location['zip']&.squeeze(' ')&.upcase,
        country_name:     'United Kingdom'.freeze
      }
    end

    # Brand of the cinema
    # @return [String] which will always be 'Everyman'
    def brand
      'Everyman'.freeze
    end

    # @return [Float, nil]
    def latitude
      theater.dig('practicalInfo', 'coordinates', 'latitude')
    end

    # @return [Float, nil]
    def longitude
      theater.dig('practicalInfo', 'coordinates', 'longitude')
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   EverymanUk::Cinema.new('X0712').name
    #   #=> 'Baker Street'
    def name
      theater['name'].to_s
    end

    # @return [String] e.g. 'Europe/London'
    def time_zone
      theater.fetch('timeZone', 'Europe/London')
    end

    # The url of the cinema on the Everyman website
    # @return [String]
    def url
      EverymanUk::Internal::ApiResponse::BASE_URL + theater['path'].to_s
    end

    # @api private
    def self.theaters_hash
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if @theaters_hash.nil? || now - @fetched_at > CACHE_SECONDS
        @fetched_at = now
        @theaters_hash = EverymanUk::Internal::ApiResponse.new.theaters
                                                          .select { |theater| open_in_uk?(theater) }
                                                          .to_h { |theater| [theater.fetch('id'), theater] }
      end
      @theaters_hash
    end
    private_class_method :theaters_hash

    def self.open_in_uk?(theater)
      theater.dig('country', 'iso31661A2') == 'GB' && !theater.dig('practicalInfo', 'closed')
    end
    private_class_method :open_in_uk?

    private

    def theater
      self.class.send(:theaters_hash).fetch(id, {})
    end
  end
end
