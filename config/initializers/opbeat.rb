Opbeat.configure do |config|
  config.organization_id = ENV['API_OPBEAT_ORGANISATION_ID']
  config.app_id = ENV['API_OPBEAT_APP_ID']
  config.secret_token = ENV['API_OPBEAT_SECRET_TOKEN']
  config.async = ->(event) { Thread.new { Opbeat.send(event) } }
end if Rails.env.production?
