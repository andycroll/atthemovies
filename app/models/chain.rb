require "cinebase/vista"

class Chain
  CHAINS = {
    "cineworld" => { gem: "CineworldUk", vista_url: "https://digital-api.cineworld.co.uk/ocapi/v1/", region_code: "GB" },
    "odeon" => { gem: "OdeonUk", vista_url: "https://vwc.odeon.co.uk/WSVistaWebClient/ocapi/v1/", region_code: "UK" },
    "picturehouse" => { gem: "PicturehouseUk", vista_url: "https://digital-api.picturehouses.com/ocapi/v1/", region_code: nil },
    "vue" => { gem: "VueUk" }
  }.freeze

  # Vue answers every advertised date in one request; the horizon only bounds it
  ADVERTISED_HORIZON = 1.year

  attr_reader :key

  def self.all
    CHAINS.keys.map { |key| new(key) }
  end

  def initialize(key)
    @key = key
    @config = CHAINS.fetch(key)
  end

  def source
    "#{key}_venue"
  end

  def authenticate!
    namespace.acquire_token! if namespace.respond_to?(:acquire_token!)
  end

  def cinemas
    namespace::Cinema.all
  end

  def performances(cinema_id)
    if @config[:vista_url]
      screening_dates(cinema_id).flat_map do |date|
        namespace::Performance.at(cinema_id, from: date, to: date)
      end
    else
      today = Time.zone.today
      namespace::Performance.at(cinema_id, from: today, to: today + ADVERTISED_HORIZON)
    end
  end

  private

  def namespace
    @config.fetch(:gem).constantize
  end

  def screening_dates(cinema_id)
    client = Cinebase::Vista::Client.new(base_url: @config[:vista_url], region_code: @config[:region_code], token: namespace.token)
    response = client.get("film-screening-dates", "siteIds" => cinema_id.to_s.rjust(3, "0"))
    dates = response.fetch("filmScreeningDates").map { |entry| Date.iso8601(entry.fetch("businessDate")) }
    dates.uniq.sort.select { |date| date >= Time.zone.today }
  end
end
