# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Atthemovies
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.assets.js_compressor = :uglifier
    config.i18n.enforce_available_locales = true
    config.active_job.queue_adapter = :delayed_job
    config.time_zone = 'Europe/London'
  end
end
