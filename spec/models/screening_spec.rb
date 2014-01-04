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
end
