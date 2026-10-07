require "test_helper"

class ListingsTest < ActionDispatch::IntegrationTest
  setup do
    @film = films(:alien)
    @cinema = cinemas(:brighton)
    @performance = Performance.create!(film: @film, cinema: @cinema, starting_at: 1.hour.from_now)
  end

  test "public pages render and stale suffixes permanently redirect after renames" do
    [ root_path, films_path, cinemas_path, cinema_performances_path(@cinema, date: "today") ].each do |path|
      get path
      assert_response :success
      assert_select "h1", 1
    end
    get film_path(@film)
    assert_response :moved_permanently
    assert_redirected_to film_url(@film, suffix: "alien-1979")
    @film.update!(name: "Alien restored")
    get film_path(@film, suffix: "alien-1979")
    assert_response :moved_permanently
    follow_redirect!
    assert_select "link[rel=canonical][href=?]", film_url(@film, suffix: "alien-restored-1979")
    get cinema_path(@cinema, suffix: @cinema.suffix)
    assert_response :success
    assert_select "nav[aria-label='Showing dates'] a", 15
  end

  test "JSON exposes public identities and conventional keys without envelopes" do
    @film.external_identifiers.create!(source: "imdb_title", value: "tt0078748")
    get "/api/films/#{@film.public_id}"
    assert_response :success
    assert_equal @film.public_id, response.parsed_body["id"]
    assert_equal({ "imdb" => "tt0078748" }, response.parsed_body["external_ids"])
    assert_equal %w[backdrop_url event external_ids id name overview performances_count poster_url runtime tagline url year], response.parsed_body.keys.sort
    get "/api/cinemas/#{@cinema.public_id}/performances"
    assert_response :success
    assert_equal @film.public_id, response.parsed_body.sole["film_id"]
    assert_equal @cinema.public_id, response.parsed_body.sole["cinema_id"]
    get "/api/films/#{@film.public_id}/cinemas"
    assert_equal [ @cinema.public_id ], response.parsed_body.map { |cinema| cinema["id"] }
  end

  test "hidden films disappear from every public listing while events remain" do
    @film.update!(event: true)
    get "/api/films"
    assert_equal [ @film.public_id ], response.parsed_body.map { |film| film["id"] }
    @film.update!(hidden: true)
    get "/api/films"
    assert_equal [], response.parsed_body
    get "/api/cinemas/#{@cinema.public_id}/performances"
    assert_equal [], response.parsed_body
    get "/api/films/#{@film.public_id}"
    assert_response :not_found
    get film_path(@film, suffix: @film.suffix)
    assert_response :not_found
  end

  test "invalid dates are rejected and undated showings redirect to today" do
    get cinema_performances_path(@cinema)
    assert_redirected_to cinema_performances_path(@cinema, date: "today")
    %w[20260230 2026-02-30 2026-1-2 nonsense].each do |date|
      get "/api/cinemas/#{@cinema.public_id}/performances", params: { date: date }
      assert_response :bad_request
    end
    get cinemas_path, params: { near: "91,0" }
    assert_response :bad_request
  end

  test "unauthenticated users cannot reach operator reads or mutations" do
    get operator_films_path
    assert_redirected_to new_session_path
    get edit_operator_cinema_path(@cinema)
    assert_redirected_to new_session_path
    patch operator_film_path(@film), params: { film: { name: "Changed" } }
    assert_redirected_to new_session_path
    patch operator_cinema_path(@cinema), params: { cinema: { name: "Changed" } }
    assert_redirected_to new_session_path
    post merge_operator_film_path(@film), params: { target_id: films(:arrival).public_id }
    assert_redirected_to new_session_path
    post search_tmdb_operator_film_path(@film)
    assert_redirected_to new_session_path
    assert_equal "Alien", @film.reload.name
    assert_equal "Duke's at Komedia", @cinema.reload.name
  end

  test "operators can update runtime, add aliases and mark no-match" do
    sign_in_as(users(:one))
    patch operator_film_path(@film), params: { film: { runtime: 118, enrichment_state: "no_match" }, alternate_name: "Alien restored" }
    assert_redirected_to edit_operator_film_path(@film)
    assert_equal 118, @film.reload.runtime
    assert_equal "no_match", @film.enrichment_state
    assert_equal @film, Film.resolve_title!("Alien restored")
    get edit_operator_film_path(@film)
    assert_response :success
    assert_select "label[for=film_runtime]"
    @film.update!(hidden: true)
    get operator_films_path, params: { q: "Alien" }
    assert_select "a[href=?]", edit_operator_film_path(@film), text: "Alien"
  end
end
