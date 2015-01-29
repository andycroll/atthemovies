class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :action_for_js, :body_class, :body_id, :controller_for_js

  def action_for_js
    case action_name
    when 'create' then 'new'
    when 'update' then 'edit'
    else action_name
    end
  end

  def body_id
    return @body_id if @body_id
    "#{controller_for_js}-#{action_for_js}"
  end

  def body_class
    return @body_class if @body_class
    "#{controller_for_js} #{action_for_js}"
  end

  def controller_for_js
    controller_path.gsub('/', '.')
  end

  private

  def http_basic_auth
    authenticate_or_request_with_http_basic('Secret!') do |user, password|
      user == ENV['HTTP_BASIC_USER'] && password == ENV['HTTP_BASIC_PASSWORD']
    end
  end
end
