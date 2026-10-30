# frozen_string_literal: true

module EverymanUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Theatres and listings from everymancinema.com
    class ApiResponse < Boxoffice::Client
      BASE_URL = "https://www.everymancinema.com"

      def initialize
        super(base_url: BASE_URL)
      end
    end
  end
end
