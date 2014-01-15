class ScreeningImporterJob < Struct.new(:cinema_id, :film_name, :showing_at, :variant)
  def perform
    cinema = Cinema.find(cinema_id)
    screening = cinema.screenings.find_or_create_by(
      film: film(film_name),
      showing_at: showing_at
    )
    screening.update_attributes(variant: variant, updated_at: Time.current)
  end

  private

  def film(name)
    Film.find_or_create_by(name: name)
  end
end
