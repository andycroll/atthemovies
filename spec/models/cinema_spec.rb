require 'rails_helper'

describe Cinema do
  describe 'associations' do
    it { is_expected.to have_many :screenings }
  end

  describe 'acts_as_url' do
    let(:cinema) { build(:cinema) }

    before { cinema.save! }

    specify { expect(cinema.url).not_to be_nil }
    specify { expect(cinema.url).to eq(cinema.name.to_url) }
  end

  describe 'geocode_by' do
    context 'no address' do
      let(:cinema) { build(:cinema) }

      before { cinema.save! }

      specify { expect(cinema.latitude).to be_nil }
      specify { expect(cinema.longitude).to be_nil }
    end

    context 'with address' do
      let(:cinema) { build(:cinema, :with_address) }

      before { cinema.save! }

      specify { expect(cinema.latitude).not_to be_nil }
      specify { expect(cinema.longitude).not_to be_nil }
    end
  end

  describe '#to_param' do
    subject { cinema.to_param }

    let!(:cinema) { create(:cinema, url: 'will-be-name-if-saved') }

    it { is_expected.to be_a(String) }
    it { is_expected.to eq("#{cinema.id}-#{cinema.url}") }
  end

  describe '#address_str' do
    subject { cinema.address_str }

    context 'missing all address parts' do
      let(:cinema) { build(:cinema) }
      it { is_expected.to be_nil }
    end

    context 'missing address parts' do
      let(:cinema) { build(:cinema, postal_code: 'BN1 6JD') }
      it { is_expected.to be_nil }
    end

    context 'only missing post code' do
      let(:cinema) { build(:cinema, street_address: '4 Eastwoods', locality: 'Brighton') }
      it { is_expected.to be_a(String) }
      it { is_expected.to include(cinema.street_address) }
      it { is_expected.to include(cinema.locality) }
    end

    context 'with address' do
      let(:cinema) { build(:cinema, :with_address) }

      it { is_expected.to be_a(String) }
      it { is_expected.to include(cinema.street_address) }
      it { is_expected.to include(cinema.locality) }
      it { is_expected.to include(cinema.postal_code) }
    end
  end

  describe '.closest_to(lat, lng)' do # provided by geocoder gem
    let!(:cinema_1) { create(:cinema, latitude: 51.5, longitude: -0.5) }
    let!(:cinema_2) { create(:cinema, latitude: 52.5, longitude: -1.5) }
    let!(:cinema_3) { create(:cinema, latitude: 52.5, longitude: -0.5) }

    subject(:closest_to) { Cinema.closest_to(50, 0) }

    it { is_expected.to eq([cinema_1, cinema_3, cinema_2]) }
  end

  describe '#update_address(address)' do
    let(:cinema) { build(:cinema) }

    subject { cinema.update_address(address_hash) }

    context 'passed address hash' do
      let(:address_hash) {
        {
          street_address: '123 New Street',
          postal_code: 'BN1 6JD'
        }
      }

      it 'updates passed address details' do
        expect { subject }.to change(cinema, :street_address)
      end
      it 'persists the cinema' do
        subject
        expect(cinema).to be_persisted
      end
    end
  end
end
