Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG']
end if Rails.env.production?
