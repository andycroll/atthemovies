# frozen_string_literal: true
require 'rails_helper'

describe Cinema do
  describe 'associations' do
    it { is_expected.to have_many :performances }
  end

  describe 'acts_as_url' do
    context 'on create' do
      let(:cinema) { build(:cinema) }

      before { cinema.save! }

      specify { expect(cinema.url).not_to be_nil }
      specify { expect(cinema.url).to eq(cinema.name.to_url) }
    end

    context 'on update' do
      let(:cinema) { create(:cinema) }

      it 'regenerates url' do
        expect {
          cinema.update_attributes(name: 'New Name')
        }.to change(cinema.reload, :url).to('new-name')
      end
    end
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

    context 'on change of address' do # bit nasty as we're testing method calls
      let!(:cinema) { create(:cinema, :with_address) }

      it 're-geocodes if address changes' do
        expect(cinema).to receive(:geocode).and_call_original
        cinema.update_attributes(postal_code: Faker::Address.postcode)
      end

      it 'does not geocode if address unchanged' do
        expect(cinema).not_to receive(:geocode)
        cinema.update_attributes(postal_code: cinema.postal_code)
      end
    end
  end

  describe '#to_param' do
    subject { cinema.to_param }

    let!(:cinema) { create(:cinema, url: 'will-be-name-if-saved') }

    it { is_expected.to be_a(String) }
    it { is_expected.to eq(cinema.url) }
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
