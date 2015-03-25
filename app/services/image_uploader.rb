class ImageUploader
  FORMAT  = 'jpg'
  QUALITY = 75

  def initialize(args)
    @width     = args.fetch(:width, 400)
    @height    = args.fetch(:height, 600)
    @url       = args.fetch(:url)
    @file_name = args.fetch(:file_name)
  end

  def store
    get_remote_image
    resize_and_encode
    save_to_storage
    return remote_url
  end

  private

  def crop_to
    "#{@width}x#{@height}#"
  end

  def get_remote_image
    @image = uploader.fetch_url(@url)
  end

  def path
    "#{@file_name}.#{FORMAT}"
  end

  def remote_url
    uploader.remote_url_for(path).sub('http:', '')
  end

  def resize_and_encode
    @image = @image.thumb(crop_to).encode(FORMAT, "-quality #{QUALITY}")
  end

  def save_to_storage
    @image.store(path: path)
  end

  def uploader
    @uploader ||= Dragonfly.app
  end
end
