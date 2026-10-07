class TmdbClient
  BASE = "https://api.themoviedb.org/3"

  def initialize(http: HttpClient.new)
    @http = http
  end

  def search(name)
    get("/search/movie?#{URI.encode_www_form(query: name)}").fetch("results")
  end

  def movie(id)
    raise ArgumentError, "TMDB ID must be numeric" unless id.to_s.match?(/\A\d+\z/)
    get("/movie/#{id}")
  end

  private
    def get(path)
      token = ENV["TMDB_ACCESS_TOKEN"].presence || Rails.application.credentials.dig(:tmdb, :access_token)
      raise HttpClient::Error, "Configure TMDB_ACCESS_TOKEN before enrichment" unless token
      JSON.parse(@http.request("#{BASE}#{path}", headers: { "Authorization" => "Bearer #{token}" }))
    end
end
