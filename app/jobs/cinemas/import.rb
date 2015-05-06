module Cinemas
  class Import < ActiveJob::Base
    attr_reader :address, :brand, :brand_identifier, :name

    def perform(args)
      @address          = args[:address]
      @brand            = args[:brand]
      @brand_identifier = args[:brand_identifier].to_s
      @name             = args[:name]
      @screenings_url   = args[:screenings_url]

      existing_or_new_cinema.update_address(address) unless existing_or_new_cinema.street_address.present?
      existing_or_new_cinema.update_attributes(screenings_url: @screenings_url)
    end

    private

    def existing_or_new_cinema
      Cinema.find_or_initialize_by(
        name:             name,
        brand:            brand,
        brand_identifier: brand_identifier
      )
    end
  end
end
