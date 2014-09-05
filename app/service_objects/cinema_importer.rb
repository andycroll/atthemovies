class CinemaImporter

  attr_reader :brand, :klass

  def initialize(options)
    @brand = options[:brand] || options[:klass].to_s.gsub('::Cinema','').gsub(/Uk\z/,'')
    @klass = options[:klass]
  end

  def import_cinemas
    remote_cinemas.each do |cinema|
      CinemaImporterJob.enqueue(
        name: cinema.full_name,
        brand: cinema.brand,
        brand_identifier: cinema.id,
        address: cinema.address
      )
    end
  end

  def import_screenings
    brand_cinemas.each do |cinema|
      import_screenings_for_cinema(cinema)
    end
  end

  def import_screenings_for_cinema(cinema)
    remote_cinema(cinema.brand_identifier).screenings.each do |s|
      ScreeningImporterJob.enqueue(
        cinema_id: cinema.id,
        film_name: s.film_name,
        showing_at: @brand == 'Cineworld' ? s.showing_at : s.when,
        variant: s.variant
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
    klass.find(brand_identifier.to_s)
  end
end
