# A presenter for the displaying of an array of Performance objects
class PerformanceGrouper
  attr_reader :performances

  def initialize(performances)
    @performances = performances
  end

  def dates
    @dates ||= performances.map { |s| s.starting_at.to_date }.uniq
  end

  def length
    performances.length
  end

  def on(date)
    performances_by_date[date.to_date] || []
  end

  private

  def performances_by_date
    @performances_by_date ||= performances.each_with_object({}) do |s, result|
      date = showing_date(s.starting_at)
      result[date] = (result[date] || []) << s
      result
    end
  end

  def showing_date(datetime)
    (datetime - 6 * 3600).to_date
  end
end
