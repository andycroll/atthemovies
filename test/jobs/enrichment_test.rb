require "test_helper"
require "minitest/mock"

class EnrichmentTest < ActiveJob::TestCase
  test "single exact match queues enrichment and ambiguous candidates remain for triage" do
    client = Object.new
    client.define_singleton_method(:search) { |name, year: nil| [ { "id" => 348, "title" => name, "release_date" => "1979-05-25" } ] }
    TmdbClient.stub(:new, client) do
      assert_enqueued_with(job: EnrichFilmJob, args: [ films(:alien) ]) { SearchTmdbJob.perform_now(films(:alien)) }
    end
    assert_equal "348", films(:alien).external_identifiers.find_by!(source: "tmdb_movie").value
    client.define_singleton_method(:search) { |_name, year: nil| [ { "id" => 1, "title" => "Arrival" }, { "id" => 2, "title" => "Arrival" } ] }
    TmdbClient.stub(:new, client) do
      assert_no_enqueued_jobs(only: EnrichFilmJob) { SearchTmdbJob.perform_now(films(:arrival)) }
    end
    assert_equal "candidates", films(:arrival).reload.enrichment_state
    assert_equal [ "1", "2" ], films(:arrival).tmdb_candidates.order(:tmdb_id).pluck(:tmdb_id)
  end

  test "a spelling that finds an already linked TMDB film merges into it" do
    films(:alien).external_identifiers.create!(source: "tmdb_movie", value: "348")
    spelling = Film.resolve_title!("Alien: The Director's Cut")
    client = Object.new
    client.define_singleton_method(:search) { |_name, year: nil| [ { "id" => 348, "title" => "Alien: The Director's Cut" } ] }
    TmdbClient.stub(:new, client) do
      assert_no_enqueued_jobs(only: EnrichFilmJob) { SearchTmdbJob.perform_now(spelling) }
    end
    assert_not Film.exists?(spelling.id)
    assert_equal films(:alien), Film.resolve_title!("Alien: The Director's Cut")
  end

  test "one exact title among several results links, ignoring articles and using original titles" do
    { [ "A Muppet Christmas Carol", nil ] => [ { "id" => 10437, "title" => "The Muppet Christmas Carol" }, { "id" => 2, "title" => "A Muppet Family Christmas" } ],
      [ "Changer l'eau des fleurs", nil ] => [ { "id" => 5, "title" => "Violette", "original_title" => "Changer l'eau des fleurs" } ],
      [ "Mookuthi Amman 2: Maha Sakthi", 2026 ] => [ { "id" => 7, "title" => "Mookuthi Amman 2", "release_date" => "2026-10-20" },
                                                    { "id" => 8, "title" => "Mookuthi Amman", "release_date" => "2020-11-14" } ] }.each do |(name, year), results|
      film = Film.resolve_title!(name, year: year)
      client = Object.new
      client.define_singleton_method(:search) { |_name, year: nil| results }
      TmdbClient.stub(:new, client) { SearchTmdbJob.perform_now(film) }
      assert_equal results.first.fetch("id").to_s, film.external_identifiers.find_by(source: "tmdb_movie")&.value, name
    end
  end

  test "a subtitle needs the film year and exact titles must be unique" do
    { [ "Alien: Romulus", nil ] => [ { "id" => 348, "title" => "Alien", "release_date" => "1979-05-25" } ],
      [ "Hamlet", nil ] => [ { "id" => 1, "title" => "Hamlet" }, { "id" => 2, "title" => "Hamlet" } ] }.each do |(name, year), results|
      film = Film.resolve_title!(name, year: year)
      client = Object.new
      client.define_singleton_method(:search) { |_name, year: nil| results }
      TmdbClient.stub(:new, client) { SearchTmdbJob.perform_now(film) }
      assert_nil film.external_identifiers.find_by(source: "tmdb_movie"), name
    end
  end

  test "search narrows by the film year and falls back to any year" do
    film = Film.resolve_title!("From Dusk Till Dawn", year: 1996)
    searches = []
    client = Object.new
    client.define_singleton_method(:search) do |name, year: nil|
      searches << [ name, year ]
      year ? [] : [ { "id" => 755, "title" => name, "release_date" => "1996-01-19" } ]
    end
    TmdbClient.stub(:new, client) { SearchTmdbJob.perform_now(film) }
    assert_equal [ [ "From Dusk Till Dawn", 1996 ], [ "From Dusk Till Dawn", nil ] ], searches
    assert_equal "755", film.external_identifiers.find_by!(source: "tmdb_movie").value
  end

  test "tmdb search sends the year as the primary release year" do
    http = Object.new
    http.define_singleton_method(:request) { |url, headers:| { results: [ { url: url } ] }.to_json }
    results = ENV.stub(:[], ->(key) { key == "TMDB_ACCESS_TOKEN" ? "token" : nil }) do
      TmdbClient.new(http: http).search("From Dusk Till Dawn", year: 1996)
    end
    assert_includes results.first.fetch("url"), "primary_release_year=1996"
    assert_includes results.first.fetch("url"), "query=From+Dusk+Till+Dawn"
  end

  test "repeat enrichment and image jobs store one set of images and correct metadata" do
    film = films(:alien)
    film.external_identifiers.create!(source: "tmdb_movie", value: "348")
    client = Object.new
    client.define_singleton_method(:movie) do |id|
      raise "wrong ID" unless id == "348"
      { "release_date" => "1979-05-25", "runtime" => 117, "imdb_id" => "tt0078748", "overview" => "In space…", "poster_path" => "/poster.png", "backdrop_path" => "/backdrop.png" }
    end
    http = Object.new
    calls = []
    http.define_singleton_method(:request) { |url| calls << url; File.binread(Rails.root.join("public/icon.png")) }
    TmdbClient.stub(:new, client) do
      HttpClient.stub(:new, http) do
        2.times do
          EnrichFilmJob.perform_now(film.reload)
          StoreFilmImagesJob.perform_now(film.reload)
        end
      end
    end
    assert_equal 2, calls.length
    assert_equal 2, ActiveStorage::Attachment.where(record: film).count
    assert_equal "matched", film.reload.enrichment_state
    assert_equal 1979, film.year
    assert_equal "In space…", film.overview
    assert_equal "tt0078748", film.external_identifiers.find_by!(source: "imdb_title").value
    assert_equal "https://image.tmdb.org/t/p/original/poster.png", film.poster.blob.metadata["source_url"]
    image = Vips::Image.new_from_buffer(film.poster.variant(:listing).processed.download, "")
    assert_operator image.width, :<=, 400
    assert_operator image.height, :<=, 600
  end

  test "upstream failures are visible and unsafe image URLs are rejected" do
    film = films(:alien)
    client = Object.new
    client.define_singleton_method(:search) { |_name, year: nil| raise HttpClient::Error, "Upstream HTTP 503" }
    TmdbClient.stub(:new, client) do
      assert_raises(HttpClient::Error) { SearchTmdbJob.new.perform(film) }
    end
    assert_equal "failed", film.reload.enrichment_state
    film.poster_source_url = "https://localhost/private.png"
    assert_not film.valid?
    assert_includes film.errors.attribute_names, :poster_source_url
  end

  test "in-flight enrichment cannot overwrite a newer operator choice" do
    film = films(:alien)
    identifier = film.external_identifiers.create!(source: "tmdb_movie", value: "348")
    client = Object.new
    client.define_singleton_method(:movie) do |_id|
      identifier.update!(value: "999")
      { "runtime" => 1, "overview" => "Stale result" }
    end
    TmdbClient.stub(:new, client) { EnrichFilmJob.perform_now(film) }
    assert_equal 117, film.reload.runtime
    assert_nil film.overview
    assert_no_enqueued_jobs(only: StoreFilmImagesJob)
  end

  test "in-flight search cannot overwrite a deliberate no-match decision" do
    film = films(:alien)
    client = Object.new
    client.define_singleton_method(:search) do |_name, year: nil|
      Film.find(film.id).update!(enrichment_state: "no_match")
      [ { "id" => 348, "title" => "Alien" } ]
    end
    TmdbClient.stub(:new, client) { SearchTmdbJob.perform_now(film) }
    assert_equal "no_match", film.reload.enrichment_state
    assert_empty film.tmdb_candidates
    assert_no_enqueued_jobs(only: EnrichFilmJob)
  end
end
