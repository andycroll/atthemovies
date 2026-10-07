class ImportPicturehouseJob < ApplicationJob
  def perform
    provider = Providers::Picturehouse.new
    provider.cinemas.each do |attributes|
      id = attributes.delete(:provider_id)
      cinema = Cinema.transaction do
        identifier = ExternalIdentifier.find_by(source: "picturehouse_venue", value: id)
        record = identifier&.identifiable || Cinema.create!(attributes)
        record.external_identifiers.create!(source: "picturehouse_venue", value: id) unless identifier
        record.update!(attributes.except(:name, :street_address, :extended_address, :locality, :postal_code))
        record
      end
      ImportCinemaPerformancesJob.perform_later(cinema)
    end
  end
end
