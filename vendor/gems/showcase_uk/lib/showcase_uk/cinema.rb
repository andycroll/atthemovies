module ShowcaseUk
  # The object representing a cinema on the Showcase Cinemas UK website
  class Cinema < Cinebase::Boxoffice::Cinema
    # @!attribute [r] id
    #   @return [String] the Boxoffice id of the cinema, e.g. 'X06JR'

    # @!method initialize(id)
    #   @param [String] id the cinema id, e.g. 'X06JR' or 'x06jr'
    #   @return [ShowcaseUk::Cinema]

    # @!method self.all
    #   Return basic cinema information for all open UK cinemas
    #   @return [Array<ShowcaseUk::Cinema>]
    #   @example
    #     ShowcaseUk::Cinema.all
    #     #=> [<ShowcaseUk::Cinema>, <ShowcaseUk::Cinema>, ...]

    # @!method adr
    #   Address of the cinema
    #   @return [Hash] contains :street_address, :extended_address,
    #   :locality, :region, :postal_code, :country_name
    #   @example
    #     cinema = ShowcaseUk::Cinema.new('X06JR')
    #     cinema.adr
    #     #=> {
    #           street_address:   'Bluewater Plaza',
    #           extended_address: nil,
    #           locality:         'Greenhithe',
    #           region:           nil,
    #           postal_code:      'DA9 9SG',
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
    #     ShowcaseUk::Cinema.new('X06JR').name
    #     #=> 'Bluewater'

    # @!method url
    #   The url of the cinema on the Showcase website
    #   @return [String]

    # @return [String]
    def self.website
      'https://www.showcasecinemas.co.uk'.freeze
    end

    # Brand of the cinema
    # @return [String] which will always be 'Showcase'
    def brand
      'Showcase'.freeze
    end
  end
end
