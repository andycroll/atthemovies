# frozen_string_literal: true
require 'spec_helper'
require_relative '../../app/presenters/performance_grouper'

describe PerformanceGrouper do
  let(:today)    { Date.today }
  let(:tomorrow) { today + 1 }

  let(:performance1) do
    double(:performance, starting_at: today.to_time + 18 * 3600)
  end
  let(:performance2) do
    double(:performance, starting_at: today.to_time + 19 * 3600)
  end
  let(:performance3) do
    double(:performance, starting_at: today.to_time + 26 * 3600)
  end
  let(:performance4) do
    double(:performance, starting_at: today.to_time + 36 * 3600)
  end
  let(:performances) do
    [performance1, performance2, performance3, performance4]
  end

  describe '#dates' do
    subject(:dates) { described_class.new(performances).dates }

    it 'returns a unique array of dates' do
      expect(dates).to eq([today, tomorrow])
    end
  end

  describe '#on(date)' do
    subject(:on) do
      described_class.new(performances).on(date)
    end

    context 'today' do
      let(:date) { today }

      it 'includes performances from date itself' do
        expect(on).to include(performance1)
        expect(on).to include(performance2)
      end

      it 'includes late night performances' do
        expect(on).to include(performance3)
      end
    end

    context 'tomorrow' do
      let(:date) { tomorrow }

      it 'includes performances from date itself' do
        expect(on).to include(performance4)
      end

      it 'does not include late night performances' do
        expect(on).not_to include(performance3)
      end
    end
  end
end
