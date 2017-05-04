# frozen_string_literal: true
require 'rails_helper'

describe Performance do
  describe 'associations' do
    it { is_expected.to belong_to :film }
    it { is_expected.to belong_to :cinema }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :cinema_id }
    it { is_expected.to validate_presence_of :film_id }
    it { is_expected.to validate_presence_of :dimension }
    it { is_expected.to validate_presence_of :starting_at }
  end

  describe 'callbacks' do
    describe 'before save' do
      it 'downcases dimension' do
        performance = create(:performance, dimension: '2D')
        expect(performance.dimension).to eq('2d')
      end

      it 'downcases variant' do
        performance = create(:performance, variant: 'IMAX D-BOX')
        expect(performance.variant).to eq('imax d-box')
      end
    end
  end

  describe 'scopes' do
    describe '.on' do
      subject { described_class.on(date) }

      before { Timecop.freeze(Time.current.at_noon) }
      after { Timecop.return }

      context 'today' do
        let!(:performance_1) do
          create(:performance, starting_at: 10.minutes.ago)
        end
        let!(:performance_2) do
          create(:performance, starting_at: 90.minutes.from_now)
        end
        let!(:performance_3) do
          create(:performance, starting_at: 40.minutes.from_now)
        end
        let!(:performance_4) do
          create(:performance,
               starting_at: 1.day.from_now.beginning_of_day + 1.minute)
        end

        let(:date) { 0.day.from_now.to_date }

        it 'returns performances for today' do
          expect(subject).to include(performance_2, performance_3)
        end

        it 'returns performances in ascending order' do
          expect(subject.first).to eq(performance_3)
          expect(subject.last).to eq(performance_2)
        end

        it 'does not include past performances' do
          expect(subject).not_to include(performance_1)
        end

        it 'does not include performances from other dates' do
          expect(subject).not_to include(performance_4)
        end
      end

      context 'tomorrow' do
        let!(:performance_1) do
          create(:performance, starting_at: 10.minutes.ago)
        end
        let!(:performance_2) do
          create(:performance, starting_at: 10.minutes.from_now)
        end
        let!(:performance_3) do
          create(:performance, starting_at: 1.day.from_now)
        end
        let!(:performance_4) do
          create(:performance,
                 starting_at: 1.day.from_now.beginning_of_day + 1.minute)
        end
        let!(:performance_5) do
          create(:performance,
                 starting_at: 2.days.from_now.beginning_of_day + 1.minute)
        end

        let(:date) { 1.day.from_now.to_date }

        it 'returns performances for tomorrow' do
          expect(subject).to include(performance_3, performance_4)
        end

        it 'returns performances in ascending order' do
          expect(subject.first).to eq(performance_4)
          expect(subject.last).to eq(performance_3)
        end

        it 'does not include past performances' do
          expect(subject).not_to include(performance_1)
        end

        it 'does not include performances from other dates' do
          expect(subject).not_to include(performance_2)
          expect(subject).not_to include(performance_5)
        end
      end
    end

    describe '.ordered' do
      subject { described_class.ordered }

      it 'returns performances in ascending time order' do
        performance_1 = create(:performance, starting_at: 3.days.from_now)
        performance_2 = create(:performance, starting_at: 2.days.from_now)

        expect(subject).to include(performance_2, performance_1)
        expect(subject.first).to eq(performance_2)
        expect(subject.last).to eq(performance_1)
      end
    end

    describe '.past' do
      subject(:past) { described_class.past }

      it 'returns past performances' do
        performance = create(:performance)
        past_performance_1 = create(:performance, starting_at: 2.days.ago)
        past_performance_2 = create(:performance, starting_at: 4.days.ago)

        expect(past).to include(past_performance_1, past_performance_2)
        expect(past).not_to include(performance)
      end
    end
  end

  describe '#update_variant!' do
    subject(:update_variant!) { performance.update_variant!('my text') }

    let(:performance) { create :performance }

    it 'changes variant text' do
      expect { update_variant! }.to change(performance, :variant).to('my text')
    end

    it 'updates timestamp' do
      expect { update_variant! }.to change(performance, :updated_at)
    end
  end
end
