require_relative 'live_helper'

# One theatre list, one week's schedule and its films: five requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_responses_are_readable
    api = EverymanUk::Internal::ApiResponse.new
    tomorrow = Date.today + 1

    assert_theaters_shape('data' => { 'allTheater' => { 'nodes' => api.theaters } })

    schedule = api.schedule('X0712', time_zone: 'Europe/London', from: tomorrow, to: tomorrow + 6)
    refute_empty schedule
    assert_schedule_shape({ 'X0712' => { 'schedule' => schedule } }, 'X0712')

    assert_movies_shape(api.movies(schedule.keys))
  end
end
