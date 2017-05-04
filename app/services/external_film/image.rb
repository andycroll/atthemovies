# frozen_string_literal: true
class ExternalFilm
  Image = Struct.new(:file_path) do
    def uri
      return unless file_path
      URI.join(base_url, 'original/', file_path.gsub(%r{\A\/}, ''))
    end

    private

    def base_url
      @base_url ||= tmdb_configuration.secure_base_url
    end

    def tmdb_configuration
      @tmdb_configuration ||= Tmdb::Configuration.new
    end
  end
end
