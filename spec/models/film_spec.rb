require 'spec_helper'

describe Film do
  describe 'validations' do
    it { should validate_presence_of :name }
  end
end
