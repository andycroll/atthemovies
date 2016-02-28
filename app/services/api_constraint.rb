class APIConstraint
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(request)
    request.format == :json && @default ||
      request.headers.fetch('Accept', '').include?(media_type)
  end

  private

  def media_type
    "application/vnd.atthemovies.v#{@version}"
  end
end
