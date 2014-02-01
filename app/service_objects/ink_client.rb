class InkClient
  include HTTParty
  base_uri 'www.filepicker.io'

  attr_accessor :handle
  attr_reader :uri

  def initialize(options={})
    @uri = options.fetch(:uri, nil)
    @handle = handle_from_url(uri.to_s) if filepicker_uri?
  end

  def store!
    unless filepicker_uri?
      self.handle = handle_from_url(parsed_store_response['url'])
      true
    end
  end

  def delete!
    if filepicker_uri?
      do_delete!
      self.handle = nil
      true
    end
  end

  private

  def api_key
    ENV['API_INK_KEY']
  end

  def do_delete!
    self.class.delete("#{uri}?key=#{api_key}")
  end

  def do_store!
    self.class.post(store_path, {body: {url: url}})
  end

  def filepicker_uri?
    uri.host.match('filepicker.io')
  end

  def handle_from_url(url)
    url.to_s.split('/').last
  end

  def parsed_store_response
    JSON.parse(do_store!)
  end

  def store_path
    "/api/store/S3?key=#{api_key}"
  end

  def url
    uri.to_s
  end
end
