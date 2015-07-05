module Import
  class Screenings
    attr_reader :brand, :klass

    def initialize(options)
      @brand = options[:brand] || options[:klass].to_s.gsub('::Cinema','').gsub(/Uk\z/,'')
      @klass = options[:klass]
    end

    def perform
      brand_cinemas.each do |cinema|
        puts "Importing #{cinema.name} (#{cinema.screenings_url})"
        perform_for(cinema)
      end
    end

    def perform_for(cinema)
      remote_cinema(cinema.brand_identifier).screenings.each do |s|
        ::Screenings::Import.perform_later(
          cinema_id:  cinema.id,
          dimension:  s.dimension,
          film_name:  s.film_name,
          showing_at: s.showing_at.to_s,
          variant:    s.variant.is_a?(Array) ? s.variant * ' ' : s.variant
        )
      end
    end

    private

    def brand_cinemas
      Cinema.where(brand: brand)
    end

    def remote_cinemas
      klass.all
    end

    def remote_cinema(brand_identifier)
      if brand == 'Odeon'
        klass.new(brand_identifier.to_s)
      else
        klass.find(brand_identifier.to_s)
      end
    end
  end
end
