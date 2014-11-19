class ExternalFilm
  class Image
    attr_reader :file_path

    def initialize(args)
      @file_path = args[:file_path]
    end

    def uri
      URI.join(base_url, 'original/', file_path.gsub(/\A\//, ''))
    end

    private

    def base_url
      tmdb_configuration.secure_base_url
    end

    def tmdb_configuration
      @tmdb_configuration ||= Tmdb::Configuration.new
    end
  end
end
