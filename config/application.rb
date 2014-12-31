require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Atthemovies
  class Application < Rails::Application
    config.assets.precompile += %w( vendor/modernizr )
    config.i18n.enforce_available_locales = true
    config.time_zone = 'Europe/London'
  end
end
