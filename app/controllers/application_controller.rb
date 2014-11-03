class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def http_basic_auth
    authenticate_or_request_with_http_basic('Secret!') do |user, password|
      user == ENV['HTTP_BASIC_USER'] && password == ENV['HTTP_BASIC_PASSWORD']
    end
  end
end
