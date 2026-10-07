require "net/http"

class HttpClient
  class Error < StandardError; end

  def request(url, form: nil, headers: {})
    uri = URI(url)
    request = form ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    request.set_form_data(form) if form
    headers.each { |key, value| request[key] = value }
    request["User-Agent"] = "AtTheMovies/1.0"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30, write_timeout: 10) { |http| http.request(request) }
    raise Error, "Upstream HTTP #{response.code} from #{uri.host}" unless response.is_a?(Net::HTTPSuccess)
    response.body
  end
end
