# frozen_string_literal: true
require 'rails_helper'

describe Api::V1::CinemasController, type: :request do
  describe '#GET index' do
    let(:base_headers) { { 'ACCEPT' => 'application/vnd.atthemovies.v1' } }

    let!(:cinema_1) { create(:cinema, latitude: 51.5, longitude: -0.5) }
    let!(:cinema_2) { create(:cinema, latitude: 52.5, longitude: -1.5) }
    let!(:cinema_3) { create(:cinema, latitude: 52.5, longitude: -0.5) }

    def do_request(url: '/cinemas', headers: base_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'application/json'

    describe 'with .json' do
      it 'renders JSON' do
        do_request(url: '/cinemas.json', headers: {})
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json'
      end
    end

    describe 'successful' do
      before { do_request }

      it 'includes all cinemas' do
        parsed = JSON.parse(response.body)
        expect(parsed['data'].count).to eq(3)
        cinema_ids = parsed['data'].map { |c| c['id'] }
        expect(cinema_ids).to include(cinema_1.id)
        expect(cinema_ids).to include(cinema_2.id)
        expect(cinema_ids).to include(cinema_3.id)
      end

      it 'includes full cinema data' do
        parsed = JSON.parse(response.body)
        parsed['data'].each do |c|
          expect(c['type']).to eq('cinemas')
          expect(c.keys).to contain_exactly('id', 'type', 'attributes')
          expect(c['attributes'].keys).to contain_exactly(
            'brand', 'country', 'country-code', 'extended-address', 'latitude',
            'locality', 'longitude', 'postal-code', 'name', 'street-address',
            'url')
        end
      end
    end
  end
end
