class CleanupPerformancesJob < ApplicationJob
  def perform
    Performance.where(starting_at: ...Time.current).find_each(&:destroy!)
  end
end
