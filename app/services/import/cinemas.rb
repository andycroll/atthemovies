module Import
  class Cinemas
    attr_reader :brand, :klass

    def initialize(options)
      @brand = options[:brand] || options[:klass].to_s.gsub('::Cinema','').gsub(/Uk\z/,'')
      @klass = options[:klass]
    end

    def perform
      remote_cinemas.each do |cinema|
        ::Cinemas::Import.perform_later(
          name: cinema.full_name,
          brand: cinema.brand,
          brand_identifier: cinema.id,
          address: cinema.address,
          screenings_url: cinema.url
        )
      end
    end

    private

    def remote_cinemas
      klass.all
    end

    def remote_cinema(brand_identifier)
      klass.find(brand_identifier.to_s)
    end
  end
end
