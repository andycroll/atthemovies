class ApplicationController < ActionController::Base
  include IsCrawler

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

  def not_found(exception)
    if Rails.env.production? && is_crawler?(request.user_agent)
      render_404
    else
      raise exception
    end
  end

  def render_404
    render file:   Rails.root.join('public', '404.html'),
           layout: nil,
           status: :not_found
  end
end
