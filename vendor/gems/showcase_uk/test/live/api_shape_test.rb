require_relative 'live_helper'

# One theatre list, one week's schedule and its films: five requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_responses_are_readable
    api = ShowcaseUk::Cinema.client
    tomorrow = Date.today + 1

    assert_theaters_shape('data' => { 'allTheater' => { 'nodes' => api.theaters } })

    schedule = api.schedule('X06JR', time_zone: 'Europe/London', from: tomorrow, to: tomorrow + 6)
    refute_empty schedule
    assert_schedule_shape({ 'X06JR' => { 'schedule' => schedule } }, 'X06JR')

    assert_movies_shape(api.movies(schedule.keys))
  end
end
