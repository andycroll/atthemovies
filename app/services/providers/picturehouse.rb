module Providers
  class Picturehouse
    BASE = "https://www.picturehouses.com"

    def initialize(http: HttpClient.new)
      @http = http
    end

    def cinemas
      document = Nokogiri::HTML(@http.request("#{BASE}/cinema"))
      document.css("a[href^='#{BASE}/cinema/']").filter_map do |link|
        next unless link.at_css("p")
        url = link["href"]
        next unless url.match?(%r{\A#{Regexp.escape(BASE)}/cinema/[a-z0-9-]+\z})
        paragraph = link.at_css("p").dup
        locality = paragraph.at_css("span")&.text&.strip || paragraph.text.strip
        paragraph.css("span").remove
        { name: paragraph.text.strip, locality: locality, screenings_url: url }
      end.uniq { |cinema| cinema[:screenings_url] }.map do |cinema|
        page = @http.request(cinema[:screenings_url])
        id = page[/CINEMA_ID\s*=\s*['"](\d+)['"]/, 1]
        raise HttpClient::Error, "Picturehouse cinema ID missing" unless id
        information = Nokogiri::HTML(@http.request("#{cinema[:screenings_url]}/information"))
        address = information.at_css(".cinemaAdrass:not(.openingTime)")
        lines = address&.inner_html.to_s.split(/<br\s*\/?\s*>/i).map { |line| Nokogiri::HTML.fragment(line).text.strip }.compact_blank
        coordinates = information.at_css("iframe[src*='maps.google.com']")&.[]("src").to_s.match(/[?&]q=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/)
        cinema.merge(provider_id: id, brand: "Picturehouse", street_address: lines[1], extended_address: lines[2...-1]&.reject { |line| line == cinema[:locality] }&.join(", "), postal_code: lines.last, country: "United Kingdom", country_code: "GB", latitude: coordinates&.[](1), longitude: coordinates&.[](2))
      end
    end

    def performances(provider_id)
      body = @http.request("#{BASE}/api/get-movies-ajax", form: { start_date: "show_all_dates", cinema_id: provider_id, filters: "" })
      parse_performances(JSON.parse(body), provider_id)
    end

    def parse_performances(data, provider_id)
      raise HttpClient::Error, "Picturehouse unsuccessful response" unless data.fetch("response") == "success"
      data.fetch("movies").flat_map do |movie|
        movie.fetch("show_times").filter_map do |session|
          next unless session.fetch("CinemaId").to_s == provider_id.to_s
          attributes = Array(session["SessionAttributesNames"]).map(&:downcase)
          {
            name: movie.fetch("Title").strip,
            starting_at: Time.zone.iso8601(session.fetch("Showtime")),
            dimension: attributes.include?("3d") ? "3d" : "2d",
            variant: attributes.presence&.join(", ") || "standard",
            booking_url: "https://web.picturehouses.com/order/showtimes/#{provider_id}-#{session.fetch('SessionId')}/seats"
          }
        end
      end.uniq { |performance| performance.values_at(:name, :starting_at, :dimension) }
    end
  end
end
