# frozen_string_literal: true

require "net/http"

module EverymanUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Plain GET requests, retried when the connection drops
    module Http
      RETRIES = 2
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      private

      def get(url, accept:)
        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = accept
        attempts = 0
        begin
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
            http.request(request)
          end
        rescue *TRANSIENT_ERRORS
          attempts += 1
          raise if attempts > RETRIES

          sleep(attempts)
          retry
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "HTTP error #{response.code} from #{uri.host}" unless response.is_a?(Net::HTTPSuccess)

        response.body
      end
    end
  end
end
