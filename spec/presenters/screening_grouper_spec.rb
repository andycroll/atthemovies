require 'spec_helper'
require_relative '../../app/presenters/screening_grouper'

describe ScreeningGrouper do
  let(:today)    { Date.today }
  let(:tomorrow) { today + 1 }

  let(:screening1) { double(:screening, showing_at: today.to_time + 18 * 3600) }
  let(:screening2) { double(:screening, showing_at: today.to_time + 19 * 3600) }
  let(:screening3) { double(:screening, showing_at: today.to_time + 26 * 3600) }
  let(:screening4) { double(:screening, showing_at: today.to_time + 36 * 3600) }

  let(:screenings) do
    [screening1, screening2, screening3, screening4]
  end

  describe '#dates' do
    subject(:dates) { described_class.new(screenings).dates }

    it 'returns a unique array of dates' do
      expect(dates).to eq([today, tomorrow])
    end
  end

  describe '#on(date)' do
    subject(:on) do
      described_class.new(screenings).on(date)
    end

    context 'today' do
      let(:date) { today }

      it 'includes screenings from date itself' do
        expect(on).to include(screening1)
        expect(on).to include(screening2)
      end

      it 'includes late night screenings' do
        expect(on).to include(screening3)
      end
    end

    context 'tomorrow' do
      let(:date) { tomorrow }

      it 'includes screenings from date itself' do
        expect(on).to include(screening4)
      end

      it 'does not include late night screenings' do
        expect(on).not_to include(screening3)
      end
    end
  end
end
