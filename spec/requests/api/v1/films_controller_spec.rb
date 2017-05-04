# frozen_string_literal: true
require 'rails_helper'

describe Api::V1::FilmsController, type: :request do
  describe '#GET index' do
    let(:base_headers) { { 'ACCEPT' => 'application/vnd.atthemovies.v1' } }

    let!(:film_no_performances) { create(:film) }
    let!(:performance) { create(:performance) }

    def do_request(url: '/films', headers: base_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'application/json'

    describe 'with .json' do
      it 'renders JSON' do
        do_request(url: '/films.json', headers: {})
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json'
      end
    end

    describe 'successful' do
      before { do_request }

      it 'includes all films with performances' do
        parsed = JSON.parse(response.body)
        expect(parsed['data'].count).to eq(1)
        film_ids = parsed['data'].map { |c| c['id'] }
        expect(film_ids).to include(performance.film.id)
        expect(film_ids).not_to include(film_no_performances.id)
      end

      it 'includes full film data' do
        parsed = JSON.parse(response.body)
        parsed['data'].each do |c|
          expect(c['type']).to eq('films')
          expect(c.keys).to contain_exactly('id', 'type', 'attributes')
          expect(c['attributes'].keys).to contain_exactly(
            'backdrop', 'name', 'overview', 'performances-count', 'poster',
            'runtime', 'tagline', 'tmdb-identifier', 'year'
          )
        end
      end
    end
  end
end
