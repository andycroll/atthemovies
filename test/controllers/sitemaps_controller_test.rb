require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "lists the index pages, every cinema and every film now showing" do
    travel_to Time.zone.local(2026, 10, 22, 12)
    alien = films(:alien)
    hidden = Film.create!(name: "Hidden", public_id: "hiddenPublicToken12345678", hidden: true)
    [ alien, hidden ].each { Performance.create!(film: it, cinema: cinemas(:brighton), starting_at: 1.hour.from_now) }
    Performance.create!(film: films(:arrival), cinema: cinemas(:brighton), starting_at: 1.day.ago)

    get sitemap_path

    assert_response :success
    assert_equal "application/xml", response.media_type
    locations = Nokogiri::XML(response.body).remove_namespaces!.xpath("//url/loc").map(&:text)
    assert_equal [
      root_url, films_url, cinemas_url,
      cinema_url(cinemas(:brighton), suffix: "duke-s-at-komedia-brighton"),
      cinema_url(cinemas(:london), suffix: "greenwich-picturehouse"),
      film_url(alien, suffix: "alien-1979")
    ].sort, locations.sort
  end
end
