# The parts of Showcase responses the gem reads. Checked against the
# hand-written fixtures and, in the live suite, against real responses held
# only in memory.
module ApiShapes
  BUILD_URL = Cinebase::Boxoffice::Client::BUILD_URL

  private

  def assert_home_page_shape(html)
    assert_match BUILD_URL, html
  end

  def assert_page_data_shape(data)
    hashes = data.fetch('staticQueryHashes')
    refute_empty hashes
    hashes.each { |hash| assert_match(/\A\d+\z/, hash) }
  end

  def assert_theaters_shape(data)
    theaters = data.fetch('data').fetch('allTheater').fetch('nodes')
    refute_empty theaters
    theaters.each do |theater|
      assert_match(/\A[A-Z0-9]{5}\z/, theater.fetch('id'))
      assert_kind_of String, theater.fetch('name')
      assert_match(%r{\A/theaters/[a-z0-9-]+\z}, theater.fetch('path'))
      assert_kind_of String, theater.fetch('timeZone')
      assert_kind_of String, theater.fetch('country').fetch('iso31661A2')
      info = theater.fetch('practicalInfo')
      assert_includes [true, false], info.fetch('closed')
      coordinates = info.fetch('coordinates')
      coordinates&.values_at('latitude', 'longitude')&.each { |value| assert_kind_of Numeric, value }
      location = info.fetch('location')
      %w(address city zip).each { |key| assert_kind_of String, location.fetch(key) }
    end
  end

  def assert_schedule_shape(data, theater_id)
    schedule = data.fetch(theater_id).fetch('schedule')
    schedule.each do |movie_id, days|
      assert_match(/\A\d+\z/, movie_id)
      days.each do |day, showtimes|
        assert_match(/\A\d{4}-\d{2}-\d{2}\z/, day)
        showtimes.each { |showtime| assert_showtime_shape(showtime) }
      end
    end
  end

  def assert_showtime_shape(showtime)
    assert_match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\z/, showtime.fetch('startsAt'))
    showtime.fetch('tags').each { |tag| assert_match(/\A[A-Z]\w*(\.\w+)+\z/, tag) }
    showtime.fetch('data').fetch('ticketing').each do |ticketing|
      assert_kind_of String, ticketing.fetch('provider')
      ticketing.fetch('urls').each { |url| assert_match(%r{\Ahttps://}, url) }
    end
  end

  def assert_movies_shape(movies)
    refute_empty movies
    movies.each do |movie|
      assert_match(/\A\d+\z/, movie.fetch('id'))
      assert_kind_of String, movie.fetch('title')
    end
  end
end
