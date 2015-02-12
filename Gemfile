source 'https://rubygems.org'

ruby '2.2.0'
gem 'rails', '4.2.0'
gem 'pg'

gem 'uglifier'
gem 'coffee-rails', '~> 4'
gem 'sass-rails', '~> 5.0'

gem 'turbolinks'
gem 'local_time'

gem 'cineworld_uk'
gem 'geocoder'
gem 'kaminari'
gem 'odeon_uk'
gem 'picturehouse_uk'
gem 'rabl'
gem 'rack-timeout'
gem 'sidekiq'
gem 'stringex'
gem 'textacular'
gem 'themoviedb'

source 'https://rails-assets.org' do
  gem 'rails-assets-zepto'
end

group :development do
  gem 'rails_db_info'
  gem 'foreman'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'pry'
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'kaminari-rspec', require: 'kaminari_rspec'
  gem 'shoulda-matchers'
  gem 'timecop'
end

group :production do
  gem 'dalli'
  gem 'hirefire-resource'
  gem 'lograge'
  gem 'opbeat'
  gem 'puma'
  gem 'rails_12factor'
  gem 'skylight'
end
