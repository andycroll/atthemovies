require 'rails_helper'

describe Api::V1::Films::CinemasController, type: :request do
  describe '#GET index' do
    let(:base_url) { "/films/#{film.id}/cinemas" }
    let(:base_headers) { { 'ACCEPT' => 'application/vnd.atthemovies.v1' } }

    let!(:film) { create(:film) }
    let!(:performance_1) { create(:performance, film: film ) }
    let!(:performance_2) { create(:performance, film: film) }
    let!(:performance_other_film) { create(:performance) }
    let!(:performance_other_date) { create(:performance, film: film, starting_at: 1.day.from_now) }

    def do_request(url: base_url, headers: base_headers, params: {})
      get url, headers: headers, params: params
    end

    describe 'successful' do
      before { do_request }

      it 'includes performances from that cinema' do
        parsed = JSON.parse(response.body)
        expect(parsed['data'].count).to eq(3)
        cinema_ids = parsed['data'].map { |c| c['id'] }
        expect(cinema_ids).to include(performance_1.cinema.id)
        expect(cinema_ids).to include(performance_2.cinema.id)
        expect(cinema_ids).to include(performance_other_date.cinema.id)
      end

      it 'does not include performances from other films' do
        parsed = JSON.parse(response.body)
        cinema_ids = parsed['data'].map { |c| c['id'] }
        expect(cinema_ids).not_to include(performance_other_film.cinema.id)
      end

      it 'includes full cinema data, and relationships to film & cinema' do
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
