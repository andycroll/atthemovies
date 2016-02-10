module Import
  class Screenings
    attr_reader :brand, :klass

    def initialize(options)
      @brand = options[:brand] || options[:klass].to_s
                                                 .gsub('::Performance', '')
                                                 .gsub(/Uk\z/, '')
      @klass = options[:klass]
    end

    def perform
      brand_cinemas.each do |cinema|
        puts "Importing #{cinema.name} (#{cinema.screenings_url})"
        perform_for(cinema)
      end
    end

    def perform_for(cinema)
      remote_performances(cinema.brand_identifier).each do |s|
        ::Screenings::Import.perform_later(
          cinema_id:  cinema.id,
          dimension:  s.dimension,
          film_name:  s.film_name,
          showing_at: s.starting_at.to_s,
          variant:    s.variant.is_a?(Array) ? s.variant * ' ' : s.variant
        )
      end
    end

    private

    def brand_cinemas
      Cinema.where(brand: brand)
    end

    def remote_performances(brand_identifier)
      klass.at(brand_identifier.to_s)
    end
  end
end
