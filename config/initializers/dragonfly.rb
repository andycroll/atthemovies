require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "0d392cfbe404606fcb67197da43159de6a3fd8d63a7a2597c07bc6185a7e05d2"

  url_format "/media/:job/:name"

  datastore :s3, access_key_id:     ENV['API_AMAZON_ACCESS_KEY'],
                 bucket_name:       ENV['API_AMAZON_BUCKET'],
                 region:            ENV['API_AMAZON_REGION'],
                 secret_access_key: ENV['API_AMAZON_SECRET_KEY'],
                 root_path:         Rails.env.production? ? 'p' : 'dev'
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
