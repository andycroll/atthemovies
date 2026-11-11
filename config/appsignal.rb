# config/appsignal.rb
Appsignal.configure do |config|
  config.activate_if_environment(:production)
  config.name = "At The Movies"
  config.push_api_key = ENV.fetch("APPSIGNAL_PUSH_API_KEY") { Rails.application.credentials.dig(:appsignal, :push_api_key) }
end
