source 'https://rubygems.org'

ruby '2.3.0'
gem 'mime-types', require: 'mime/types/columnar' # free memory

gem 'rails', '~> 5.0.0.1'
gem 'pg'

gem 'uglifier'
gem 'coffee-rails', '~> 4'
gem 'sass-rails', '~> 5.0'

gem 'turbolinks'
gem 'local_time'

gem 'active_model_serializers'
gem 'delayed_job_active_record'
gem 'cineworld_uk'
gem 'dragonfly'
gem 'dragonfly-s3_data_store'
gem 'geocoder'
gem 'is_crawler'
gem 'kaminari'
gem 'odeon_uk'
gem 'picturehouse_uk'
gem 'rack-timeout'
gem 'stringex'
gem 'textacular', git: 'git@github.com:textacular/textacular'
gem 'themoviedb'

source 'https://rails-assets.org' do
  gem 'rails-assets-zepto'
end

group :development do
  gem 'derailed'
  gem 'foreman'
  gem 'rails_db_info'
  gem 'web-console'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'pry-rails'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'danger', require: nil
  gem 'danger-rubocop', require: nil
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'kaminari-rspec', require: 'kaminari_rspec'
  gem 'shoulda-matchers'
  gem 'timecop'
end

group :production do
  gem 'dalli'
  gem 'lograge'
  gem 'puma'
  gem 'rails_12factor'
  gem 'skylight'
end
