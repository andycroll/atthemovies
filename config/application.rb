require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Atthemovies
  class Application < Rails::Application
    config.assets.js_compressor = :uglifier
    config.i18n.enforce_available_locales = true
    config.active_job.queue_adapter = :delayed_job
    config.time_zone = 'Europe/London'
  end
end
