require "test_helper"

class ConcurrentImportTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "concurrent imports converge to one film and one performance" do
    cinema_id = cinemas(:brighton).id
    attributes = { name: "Concurrent Release", starting_at: Time.utc(2027, 1, 1, 19), dimension: "2d", variant: "standard" }
    ready = Queue.new
    start = Queue.new
    threads = 4.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop
          ImportCinemaPerformancesJob.new.import!(Cinema.find(cinema_id), attributes)
        end
      end
    end
    4.times { ready.pop }
    4.times { start << true }
    threads.each(&:value)
    film = Film.find_by!(name: "Concurrent Release")
    assert_equal 1, Film.where(name: "Concurrent Release").count
    assert_equal 1, film.performances.count
    assert_equal 1, film.performances_count
  ensure
    threads&.each(&:join)
    Film.where(name: "Concurrent Release").destroy_all
  end
end
