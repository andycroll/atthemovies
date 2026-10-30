module EverymanUk
  # The object representing a cinema on the Everyman website
  class Cinema < Cinebase::Boxoffice::Cinema
    # @!attribute [r] id
    #   @return [String] the Boxoffice id of the cinema, e.g. 'X0712'

    # @!method initialize(id)
    #   @param [String] id the cinema id, e.g. 'X0712' or 'x0712'
    #   @return [EverymanUk::Cinema]

    # @!method self.all
    #   Return basic cinema information for all open UK cinemas
    #   @return [Array<EverymanUk::Cinema>]
    #   @example
    #     EverymanUk::Cinema.all
    #     #=> [<EverymanUk::Cinema>, <EverymanUk::Cinema>, ...]

    # @!method adr
    #   Address of the cinema
    #   @return [Hash] contains :street_address, :extended_address,
    #   :locality, :region, :postal_code, :country_name
    #   @example
    #     cinema = EverymanUk::Cinema.new('X0712')
    #     cinema.adr
    #     #=> {
    #           street_address:   '96-98 Baker Street',
    #           extended_address: nil,
    #           locality:         'London',
    #           region:           nil,
    #           postal_code:      'W1U 6TJ',
    #           country_name:     'United Kingdom'
    #         }
    #   @note Uses method naming as at http://microformats.org/wiki/adr

    # @!method latitude
    #   @return [Float, nil]

    # @!method longitude
    #   @return [Float, nil]

    # @!method name
    #   The name of the cinema
    #   @return [String]
    #   @example
    #     EverymanUk::Cinema.new('X0712').name
    #     #=> 'Baker Street'

    # @!method url
    #   The url of the cinema on the Everyman website
    #   @return [String]

    # @return [String]
    def self.website
      'https://www.everymancinema.com'.freeze
    end

    # Brand of the cinema
    # @return [String] which will always be 'Everyman'
    def brand
      'Everyman'.freeze
    end
  end
end
