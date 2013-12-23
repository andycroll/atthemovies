require 'spec_helper'

describe Cinema do
  describe 'acts_as_url' do
    let(:cinema) { build(:cinema) }

    before { cinema.save! }

    specify { cinema.url.should_not be_nil }
    specify { cinema.url.should eq(cinema.name.to_url) }
  end

  describe 'geocode_by' do
    context 'no address' do
      let(:cinema) { build(:cinema) }

      before { cinema.save! }

      specify { cinema.latitude.should be_nil }
      specify { cinema.longitude.should be_nil }
    end

    context 'with address' do
      let(:cinema) { build(:cinema, :with_address) }

      before { cinema.save! }

      specify { cinema.latitude.should_not be_nil }
      specify { cinema.longitude.should_not be_nil }
    end
  end

  describe '#address_str' do
    subject { cinema.address_str }

    context 'missing all address parts' do
      let(:cinema) { build(:cinema) }
      it { should be_nil }
    end

    context 'missing address parts' do
      let(:cinema) { build(:cinema, postal_code: 'BN1 6JD') }
      it { should be_nil }
    end

    context 'only missing post code' do
      let(:cinema) { build(:cinema, street_address: '4 Eastwoods', locality: 'Brighton') }
      it { should be_a(String) }
      it { should include(cinema.street_address) }
      it { should include(cinema.locality) }
    end

    context 'with address' do
      let(:cinema) { build(:cinema, :with_address) }

      it { should be_a(String) }
      it { should include(cinema.street_address) }
      it { should include(cinema.locality) }
      it { should include(cinema.postal_code) }
    end
  end
end
