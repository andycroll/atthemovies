class ImportChainJob < ApplicationJob
  retry_on Cinebase::Vista::AuthenticationError, wait: :polynomially_longer, attempts: 5

  def perform(key)
    chain = Chain.new(key)
    chain.authenticated do
      chain.cinemas.each do |venue|
        cinema = Cinema.transaction do
          identifier = ExternalIdentifier.find_by(source: chain.source, value: venue.id.to_s)
          attributes = cinema_attributes(venue)
          record = identifier&.identifiable || Cinema.create!(attributes)
          record.external_identifiers.create!(source: chain.source, value: venue.id.to_s) unless identifier
          record.update!(attributes.slice(:brand, :screenings_url))
          record.update!(attributes.slice(:latitude, :longitude)) if record.latitude.blank? && record.longitude.blank?
          record
        end
        ImportChainPerformancesJob.perform_later(cinema, key)
      end
    end
  end

  private

  def cinema_attributes(venue)
    {
      name: venue.name,
      brand: venue.brand,
      street_address: venue.street_address.presence,
      extended_address: venue.extended_address.presence,
      locality: venue.locality.presence,
      region: venue.region.presence,
      postal_code: venue.postal_code.presence,
      country: "United Kingdom",
      country_code: "GB",
      latitude: venue.try(:latitude),
      longitude: venue.try(:longitude),
      screenings_url: venue.url.to_s.sub("http://", "https://").presence
    }
  end
end
