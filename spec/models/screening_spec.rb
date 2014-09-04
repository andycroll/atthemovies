require 'rails_helper'

describe Screening do
  describe 'associations' do
    it { is_expected.to belong_to :film }
    it { is_expected.to belong_to :cinema }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :showing_at }
    it { is_expected.to validate_presence_of :variant }
  end

  describe 'scopes' do
    describe 'default' do
      subject { Screening.all }

      it 'returns screenings in ascending time order' do
        screening_1 = create(:screening, showing_at: 3.days.from_now )
        screening_2 = create(:screening, showing_at: 2.days.from_now )

        expect(subject).to include(screening_2, screening_1)
        expect(subject.first).to eq(screening_2)
        expect(subject.last).to eq(screening_1)
      end
    end

    describe '.past' do
      subject(:past) { Screening.past }

      it 'returns past screenings' do
        screening = create(:screening)
        past_screening_1 = create(:screening, showing_at: 2.days.ago )
        past_screening_2 = create(:screening, showing_at: 4.days.ago )

        expect(past).to include(past_screening_1, past_screening_2)
        expect(past).not_to include(screening)
      end
    end
  end

  describe '#set_variant' do
    subject(:set_variant) { screening.set_variant('my text') }

    let(:screening) { create :screening }

    it 'changes variant text' do
      expect { set_variant }.to change(screening, :variant).to('my text')
    end

    it 'updates timestamp' do
      expect { set_variant }.to change(screening, :updated_at)
    end
  end
end
