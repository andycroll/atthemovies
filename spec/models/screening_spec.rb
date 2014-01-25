require 'spec_helper'

describe Screening do
  describe 'associations' do
    it { should belong_to :film }
    it { should belong_to :cinema }
  end

  describe 'validations' do
    it { should validate_presence_of :showing_at }
    it { should validate_presence_of :variant }
  end

  describe '#set_variant' do
    let(:screening) { create :screening }
    subject { screening.set_variant('my text') }

    it 'changes variant text' do
      expect { subject }.to change(screening, :variant).to('my text')
    end
    it 'updates timestamp' do
      expect { subject }.to change(screening, :updated_at)
    end
  end
end
