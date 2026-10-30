require_relative 'fixtures_helper'

class FakeClient
  include FixturesHelper

  attr_reader :movie_requests, :schedule_requests

  def initialize
    @movie_requests = []
    @schedule_requests = []
  end

  def theaters
    JSON.parse(theaters_json).dig('data', 'allTheater', 'nodes')
  end

  def schedule(theater_id, time_zone:, from:, to:)
    @schedule_requests << { theater_id: theater_id, time_zone: time_zone, from: from, to: to }
    JSON.parse(schedule_json(theater_id)).dig(theater_id, 'schedule')
  end

  def movies(ids)
    @movie_requests << ids
    JSON.parse(movies_json).select { |movie| ids.include?(movie['id']) }
  end
end
