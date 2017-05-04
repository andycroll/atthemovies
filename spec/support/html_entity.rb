# frozen_string_literal: true
# Replicate the ActiveSupport h helper for text checking against HTML
module HtmlEntityHelper
  def h(s)
    CGI.escapeHTML(s)
  end
end
