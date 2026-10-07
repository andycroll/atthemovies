require "test_helper"

class PicturehouseTest < ActiveSupport::TestCase
  test "cross-venue sessions are filtered and UK local showtimes become correct UTC times" do
    data = { "response" => "success", "movies" => [ { "Title" => "Tabby McTat", "show_times" => [
      { "CinemaId" => "019", "SessionId" => "41330", "Showtime" => "2026-10-08T10:30:00", "SessionAttributesNames" => [ "3D", "Toddler Ti" ] },
      { "CinemaId" => "020", "SessionId" => "999", "Showtime" => "2026-10-08T11:00:00" },
      { "CinemaId" => "019", "SessionId" => "41331", "Showtime" => "2026-12-08T10:30:00" }
    ] } ] }
    performances = Providers::Picturehouse.new.parse_performances(data, "019")
    assert_equal 2, performances.size
    assert_equal Time.utc(2026, 10, 8, 9, 30), performances.first[:starting_at]
    assert_equal Time.utc(2026, 12, 8, 10, 30), performances.last[:starting_at]
    assert_equal "3d", performances.first[:dimension]
    assert_equal "3d, toddler ti", performances.first[:variant]
    assert_equal "https://web.picturehouses.com/order/showtimes/019-41330/seats", performances.first[:booking_url]
  end

  test "cinema parser separates numeric identity, name, locality and address" do
    http = Object.new
    http.define_singleton_method(:request) do |url|
      case url
      when "https://www.picturehouses.com/cinema"
        '<a href="https://www.picturehouses.com/cinema/duke-s-at-komedia"><p>Duke\'s at Komedia<span>Brighton</span></p></a><a href="https://www.picturehouses.com/cinema/chester-picturehouse"><p>Chester</p></a>'
      when /information$/
        '<div class="cinemaAdrass">Duke\'s at Komedia<br>44–47 Gardner Street<br>Brighton<br>East Sussex<br>BN1 1UN</div><iframe src="https://maps.google.com/maps?q=50.8248,-0.1394&amp;output=embed"></iframe>'
      else
        "CINEMA_ID = '019';"
      end
    end
    cinemas = Providers::Picturehouse.new(http: http).cinemas
    assert_equal 2, cinemas.size
    assert_equal "Chester", cinemas.last[:locality]
    cinema = cinemas.first
    assert_equal "019", cinema[:provider_id]
    assert_equal "Duke's at Komedia", cinema[:name]
    assert_equal "Brighton", cinema[:locality]
    assert_equal "44–47 Gardner Street", cinema[:street_address]
    assert_equal "BN1 1UN", cinema[:postal_code]
    assert_equal "50.8248", cinema[:latitude]
    assert_equal "-0.1394", cinema[:longitude]
  end

  test "provider errors are not treated as empty successful listings" do
    assert_raises(HttpClient::Error) { Providers::Picturehouse.new.parse_performances({ "response" => "error" }, "019") }
  end
end
