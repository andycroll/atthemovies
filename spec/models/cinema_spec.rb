require 'spec_helper'

describe Cinema do
  describe 'acts_as_url' do
    let(:cinema) { build(:cinema) }

    before { cinema.save! }

    specify { cinema.url.should_not be_nil }
    specify { cinema.url.should eq(cinema.name.to_url) }
  end

  describe 'geocode_by' do
    let(:cinema) { build(:cinema) }

    before { cinema.save! }

    specify { cinema.latitude.should_not be_nil }
    specify { cinema.longitude.should_not be_nil }
  end

  describe '#address_str' do
    subject { cinema.address_str }

    let(:cinema) { build(:cinema) }

    it { should be_a(String) }
    it { should include(cinema.street_address) }
    it { should include(cinema.locality) }
    it { should include(cinema.postal_code) }
  end
end
