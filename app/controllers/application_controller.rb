# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include IsCrawler

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  helper_method :action_for_js, :controller_for_js

  def action_for_js
    return @action_for_js if @action_for_js
    case action_name
    when 'create' then 'new'
    when 'update' then 'edit'
    else action_name
    end
  end

  def controller_for_js
    return @controller_for_js if @controller_for_js
    controller_path.tr('/', '.')
  end

  private

  def http_basic_auth
    authenticate_or_request_with_http_basic('Secret!') do |user, password|
      user == ENV['HTTP_BASIC_USER'] && password == ENV['HTTP_BASIC_PASSWORD']
    end
  end

  def not_found(exception)
    if Rails.env.production? && is_crawler?(request.user_agent) || request.path.include?('.php')
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
