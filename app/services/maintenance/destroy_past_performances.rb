# frozen_string_literal: true
module Maintenance
  class DestroyPastPerformances
    def perform
      Performance.past.destroy_all
    end
  end
end
