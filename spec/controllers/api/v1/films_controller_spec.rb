require 'rails_helper'

describe Api::V1::FilmsController do
  render_views

  describe 'routes' do
    describe 'with http "Accept" header' do
      before do
        Rack::MockRequest::DEFAULT_ENV['HTTP_ACCEPT'] =
          'application/vnd.atthemovies.v1'
      end

      after { Rack::MockRequest::DEFAULT_ENV.delete 'HTTP_ACCEPT' }

      specify do
        expect(get: '/films.json').to route_to(controller: 'api/v1/films',
                                               action: 'index',
                                               format: 'json')
      end

      specify do
        expect(get: '/films').to route_to(controller: 'api/v1/films',
                                          action: 'index')
      end
    end

    describe 'with specified format' do
      specify do
        expect(get: '/films.json').to route_to(controller: 'api/v1/films',
                                               action: 'index',
                                               format: 'json')
      end
    end
  end

  describe '#GET index' do
    let!(:film_no_performances) { create(:film) }
    let!(:performance) { create(:performance) }

    def get_index(params = {})
      request.env['HTTP_ACCEPT'] = 'application/vnd.atthemovies.v1'
      get :index, {}.merge(params)
    end

    describe 'successful' do
      before { get_index }

      it { is_expected.to respond_with :success }

      specify { expect(response.content_type).to eq 'application/json' }

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
            'backdrop', 'name', 'overview', 'poster', 'runtime', 'tagline',
            'tmdb-identifier', 'year')
        end
      end
    end
  end
end
