CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
    config.enable_processing = true

  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false

  else
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['API_AMAZON_ACCESS_KEY'],
      :aws_secret_access_key  => ENV['API_AMAZON_SECRET_KEY'],
      :region                 => 'us-west-2'
    }
    config.fog_directory  = ENV['API_AMAZON_BUCKET']
    config.fog_public     = true
    config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}

    config.root = Rails.root.join('tmp')
    config.cache_dir = 'carrierwave'
  end

end

# monkey patch for suffixed versions
# https://github.com/carrierwaveuploader/carrierwave/wiki/How-To:-Move-version-name-to-end-of-filename,-instead-of-front
module CarrierWave
  module Uploader
    module Versions
      def full_filename(for_file)
        parent_name = super(for_file)
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end

      def full_original_filename
        parent_name = super
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end
    end
  end
end
