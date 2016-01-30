Rails.application.configure do |config|
  config.opbeat.app_id = ENV['API_OPBEAT_APP_ID']
  config.opbeat.organization_id = ENV['API_OPBEAT_ORGANISATION_ID']
  config.opbeat.secret_token = ENV['API_OPBEAT_SECRET_TOKEN']
end if Rails.env.production?
