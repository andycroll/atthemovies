class ImportCineworldJob < ApplicationJob
  retry_on CineworldUk::AuthenticationError, wait: :polynomially_longer, attempts: 5

  def perform
    CineworldUk.acquire_token!
    CineworldUk::Cinema.all.each do |venue|
      cinema = Cinema.transaction do
        identifier = ExternalIdentifier.find_by(source: "cineworld_venue", value: venue.id.to_s)
        attributes = venue.adr.merge(name: venue.name, brand: venue.brand, country_code: "GB",
          screenings_url: venue.url.sub("http://", "https://"))
        record = identifier&.identifiable || Cinema.create!(attributes)
        record.external_identifiers.create!(source: "cineworld_venue", value: venue.id.to_s) unless identifier
        record.update!(attributes.slice(:screenings_url))
        record
      end
      ImportCineworldPerformancesJob.perform_later(cinema)
    end
  end
end
