require "application_system_test_case"

class ListingsSystemTest < ApplicationSystemTestCase
  test "browse canonical films, search and navigate cinema dates" do
    film = films(:alien)
    cinema = cinemas(:brighton)
    Performance.create!(film: film, cinema: cinema, starting_at: Date.tomorrow.in_time_zone + 19.hours)
    visit root_url
    click_on "Explore films"
    fill_in "Search films", with: "Alien"
    click_on "Search"
    click_on "Alien"
    assert_selector "h1", text: "Alien"
    assert_current_path film_path(film, suffix: "alien-1979")
    click_on "Duke's at Komedia"
    click_on "Tomorrow"
    assert_selector "h2", text: "Alien"
    assert_selector "span", text: "19:00"
    take_screenshot
  end

  test "operator sign-in and film edit persist through Turbo forms" do
    films(:alien).tmdb_candidates.create!(tmdb_id: "348", name: "Alien", year: 1979)
    visit edit_operator_film_url(films(:alien))
    assert_selector "h1", text: "Operator sign in"
    fill_in "Email address", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_selector "h1", text: "Edit Alien"
    assert_no_selector "html[aria-busy='true']"
    fill_in "Runtime", with: "118"
    fill_in "Add alternate title", with: "Alien restored"
    select "no_match", from: "Metadata state"
    click_on "Save film"
    assert_text "Film saved."
    assert_equal 118, films(:alien).reload.runtime
    assert_equal films(:alien), Film.resolve_title!("Alien restored")
    take_screenshot
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    assert_button "Choose"
    assert_button "Merge"
    take_screenshot
    visit edit_operator_cinema_url(cinemas(:brighton))
    fill_in "Name", with: "Brighton Picturehouse"
    fill_in "Postal code", with: "BN1 1UN"
    take_screenshot
    click_on "Save cinema"
    assert_selector "h1", text: "Brighton Picturehouse"
    assert_current_path cinema_path(cinemas(:brighton).reload, suffix: "brighton-picturehouse")
    click_on "Sign out"
    visit operator_films_url
    assert_selector "h1", text: "Operator sign in"
  end
end
