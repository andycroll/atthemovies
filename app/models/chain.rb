require "cinebase/vista"

class Chain
  CHAINS = {
    "arc" => { gem: "ArcUk" },
    "cineworld" => { gem: "CineworldUk", vista_url: "https://digital-api.cineworld.co.uk/ocapi/v1/", region_code: "GB" },
    "curzon" => { gem: "CurzonUk", vista_url: "https://digital-api.curzon.com/ocapi/v1/", region_code: nil },
    "depot" => { gem: "DepotUk" },
    "everyman" => { gem: "EverymanUk" },
    "gft" => { gem: "GftUk" },
    "light" => { gem: "LightUk" },
    "merlin" => { gem: "MerlinUk" },
    "moviehouse" => { gem: "MoviehouseUk" },
    "odeon" => { gem: "OdeonUk", vista_url: "https://vwc.odeon.co.uk/WSVistaWebClient/ocapi/v1/", region_code: "UK" },
    "omniplex" => { gem: "OmniplexUk" },
    "picturehouse" => { gem: "PicturehouseUk", vista_url: "https://digital-api.picturehouses.com/ocapi/v1/", region_code: nil },
    "princecharles" => { gem: "PrincecharlesUk" },
    "reel" => { gem: "ReelUk" },
    "rio" => { gem: "RioUk" },
    "scott" => { gem: "ScottUk" },
    "showcase" => { gem: "ShowcaseUk" },
    "spektrix" => { gem: "SpektrixUk" },
    "vue" => { gem: "VueUk" },
    "watershed" => { gem: "WatershedUk" }
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
    namespace.ensure_token! if namespace.respond_to?(:ensure_token!)
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
    token = namespace.token
    client = Cinebase::Vista::Client.new(base_url: @config[:vista_url], region_code: @config[:region_code], token: token)
    response = begin
      client.get("film-screening-dates", "siteIds" => site_id(cinema_id))
    rescue Cinebase::Vista::AuthenticationError
      namespace.reject_token!(token)
      raise
    end
    dates = response.fetch("filmScreeningDates").map { |entry| Date.iso8601(entry.fetch("businessDate")) }
    dates.uniq.sort.select { |date| date >= Time.zone.today }
  end

  # Numeric Vista site ids are zero-padded; Curzon's are codes such as SOH1
  def site_id(cinema_id)
    id = cinema_id.to_s
    id.match?(/\A\d+\z/) ? id.rjust(3, "0") : id
  end
end
