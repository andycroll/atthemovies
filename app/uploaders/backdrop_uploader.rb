# encoding: utf-8

class BackdropUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def default_url
    ActionController::Base.helpers.asset_path("default/backdrop_#{version_name}.gif")
  end

  def filename
    "#{model.url}.backdrop.#{model.backdrop.file.extension}" if original_filename
  end

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
  end

  # version :iphone do
  #   process :scale => [640, 1136]
  # end
end
