require_relative 'live_helper'

class LiveIntegrationTest < Minitest::Test
  def test_cinemas_and_their_performances
    cinemas = EverymanUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(EverymanUk::Cinema) })
    assert_operator cinemas.size, :>, 40

    baker_street = cinemas.detect { |cinema| cinema.id == 'X0712' }
    assert_equal 'Baker Street', baker_street.name
    refute_empty baker_street.postal_code
    assert_kind_of Float, baker_street.latitude

    tomorrow = Date.today + 1
    performances = EverymanUk::Performance.at('X0712', from: tomorrow, to: tomorrow + 6)

    assert(performances.all? { |p| p.instance_of?(EverymanUk::Performance) })
    assert_operator performances.count, :>, 5
    assert(performances.all? { |p| p.booking_url&.start_with?('https://') })
  end
end
