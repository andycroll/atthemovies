# A presenter for the displaying of an array of Screening objects
class ScreeningGrouper
  def initialize(screenings)
    @screenings = screenings
  end

  def dates
    @dates ||= @screenings.map { |s| s.showing_at.to_date }.uniq
  end

  def length
    @screenings.length
  end

  def on(date)
    screenings_by_date[date.to_date] || []
  end

  def screenings
    @screenings
  end

  private

  def screenings_by_date
    @screenings_by_date ||= @screenings.each_with_object({}) do |s, result|
      date = showing_date(s.showing_at)
      result[date] = (result[date] || []) << s
      result
    end
  end

  def showing_date(datetime)
    (datetime - 6 * 3600).to_date
  end
end
