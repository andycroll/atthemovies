require_relative 'live_helper'

class LiveIntegrationTest < Minitest::Test
  def test_cinemas_and_their_performances
    cinemas = ShowcaseUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(ShowcaseUk::Cinema) })
    assert_operator cinemas.size, :>, 10

    bluewater = cinemas.detect { |cinema| cinema.id == 'X06JR' }
    assert_equal 'Bluewater', bluewater.name
    refute_empty bluewater.postal_code
    assert_kind_of Float, bluewater.latitude

    tomorrow = Date.today + 1
    performances = ShowcaseUk::Performance.at('X06JR', from: tomorrow, to: tomorrow + 6)

    assert(performances.all? { |p| p.instance_of?(ShowcaseUk::Performance) })
    assert_operator performances.count, :>, 20
    assert(performances.all? { |p| p.booking_url&.start_with?('https://tickets.showcasecinemas.co.uk/') })
  end
end
