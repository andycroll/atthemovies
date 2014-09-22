# creates screenings asynchonously from passed data
class ScreeningImporterJob < Job
  def initialize(args)
    @cinema_id  = args[:cinema_id]
    @dimension  = args[:dimension]
    @film_name  = args[:film_name]
    @showing_at = args[:showing_at]
    @variant    = args[:variant]
  end

  def perform
    @variant *= ' ' if @variant.is_a?(Array)
    existing_or_new_screening.update_variant!(@variant)
  end

  private

  def cinema
    Cinema.find(@cinema_id)
  end

  def film
    Film.find_or_create_by(name: @film_name)
  end

  def existing_or_new_screening
    cinema.screenings.find_or_initialize_by(
      film:       film,
      dimension:  @dimension,
      showing_at: @showing_at
    )
  end
end
