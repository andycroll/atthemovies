# frozen_string_literal: true
module BasicAuthHelper
  def credentials(u: ENV['HTTP_BASIC_USER'], pw: ENV['HTTP_BASIC_PASSWORD'])
    ActionController::HttpAuthentication::Basic.encode_credentials(u, pw)
  end
end
