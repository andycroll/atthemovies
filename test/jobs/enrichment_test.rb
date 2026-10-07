require "test_helper"
require "minitest/mock"

class EnrichmentTest < ActiveJob::TestCase
  test "single exact match queues enrichment and ambiguous candidates remain for triage" do
    client = Object.new
    client.define_singleton_method(:search) { |name| [ { "id" => 348, "title" => name, "release_date" => "1979-05-25" } ] }
    TmdbClient.stub(:new, client) do
      assert_enqueued_with(job: EnrichFilmJob, args: [ films(:alien) ]) { SearchTmdbJob.perform_now(films(:alien)) }
    end
    assert_equal "348", films(:alien).external_identifiers.find_by!(source: "tmdb_movie").value
    client.define_singleton_method(:search) { |_name| [ { "id" => 1, "title" => "Different title" }, { "id" => 2, "title" => "Arrival" } ] }
    TmdbClient.stub(:new, client) do
      assert_no_enqueued_jobs(only: EnrichFilmJob) { SearchTmdbJob.perform_now(films(:arrival)) }
    end
    assert_equal "candidates", films(:arrival).reload.enrichment_state
    assert_equal [ "1", "2" ], films(:arrival).tmdb_candidates.order(:tmdb_id).pluck(:tmdb_id)
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
    client.define_singleton_method(:search) { |_name| raise HttpClient::Error, "Upstream HTTP 503" }
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
    client.define_singleton_method(:search) do |_name|
      Film.find(film.id).update!(enrichment_state: "no_match")
      [ { "id" => 348, "title" => "Alien" } ]
    end
    TmdbClient.stub(:new, client) { SearchTmdbJob.perform_now(film) }
    assert_equal "no_match", film.reload.enrichment_state
    assert_empty film.tmdb_candidates
    assert_no_enqueued_jobs(only: EnrichFilmJob)
  end
end
