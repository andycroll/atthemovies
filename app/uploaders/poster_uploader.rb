# encoding: utf-8

class PosterUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def default_url
    ActionController::Base.helpers.asset_path("default/poster_#{version_name}.gif")
  end

  def filename
    "#{model.url}.poster.#{model.poster.file.extension}" if original_filename
  end

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
  end

  # version :iphone do
  #   process :scale => [640, 1136]
  # end
end
