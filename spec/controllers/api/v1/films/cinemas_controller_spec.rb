require 'rails_helper'

describe Api::V1::Films::CinemasController do
  render_views

  describe 'routes' do
    describe 'with http "Accept" header' do
      before do
        Rack::MockRequest::DEFAULT_ENV['HTTP_ACCEPT'] =
          'application/vnd.atthemovies.v1'
      end

      after { Rack::MockRequest::DEFAULT_ENV.delete 'HTTP_ACCEPT' }

      specify do
        expect(get: '/films/23/cinemas.json').to route_to(controller: 'api/v1/films/cinemas',
                                                          action: 'index',
                                                          format: 'json',
                                                          film_id: '23')

        expect(get: '/films/23/cinemas').to route_to(controller: 'api/v1/films/cinemas',
                                                     action: 'index',
                                                     film_id: '23')
      end
    end

    describe 'with specified format' do
      specify do
        expect(get: '/films/23/cinemas.json').to route_to(controller: 'api/v1/films/cinemas',
                                                          action: 'index',
                                                          format: 'json',
                                                          film_id: '23')
      end
    end
  end

  describe '#GET index' do
    let!(:film) { create(:film) }
    let!(:performance_1) { create(:performance, film: film ) }
    let!(:performance_2) { create(:performance, film: film) }
    let!(:performance_other_film) { create(:performance) }
    let!(:performance_other_date) { create(:performance, film: film, starting_at: 1.day.from_now) }

    def get_index(params = {})
      request.env['HTTP_ACCEPT'] = 'application/vnd.atthemovies.v1'
      get :index, { film_id: film.id }.merge(params)
    end

    describe 'successful' do
      before { get_index }

      it { is_expected.to respond_with :success }

      specify { expect(response.content_type).to eq 'application/json' }

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
