class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def listing_date
      case params[:date]
      when nil, "today" then Date.current
      when "tomorrow" then Date.tomorrow
      else
        raise ArgumentError, "Use YYYY-MM-DD, today or tomorrow" unless params[:date].match?(/\A\d{4}-\d{2}-\d{2}\z/)
        Date.iso8601(params[:date])
      end
    end
end
