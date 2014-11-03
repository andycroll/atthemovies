module BasicAuthHelper
  def http_login
    u =  ENV['HTTP_BASIC_USER']
    pw = ENV['HTTP_BASIC_PASSWORD']
    auth = ActionController::HttpAuthentication::Basic.encode_credentials(u,pw)
    request.env['HTTP_AUTHORIZATION'] = auth
  end
end
