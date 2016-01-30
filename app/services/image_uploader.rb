class ImageUploader
  FORMAT  = 'jpg'
  SUPER_OPTIMIZED = ['-filter Triangle', '-define filter:support=2',
                     '-unsharp 0.25x0.08+8.3+0.045', '-dither None',
                     '-posterize 136', '-quality 82',
                     '-define jpeg:fancy-upsampling=off',
                     '-define png:compression-filter=5',
                     '-define png:compression-level=9',
                     '-define png:compression-strategy=1',
                     '-define png:exclude-chunk=all', '-interlace none',
                     '-colorspace sRGB']

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
    @image =
      @image.thumb(crop_to)
            .convert(SUPER_OPTIMIZED.join(' '))
            .encode(FORMAT)
  end

  def save_to_storage
    @image.store(path: path)
  end

  def uploader
    @uploader ||= Dragonfly.app
  end
end
