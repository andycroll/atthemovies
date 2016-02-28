require 'rails_helper'

describe Api::V1::CinemasController do
  render_views

  describe 'routes' do
    describe 'with http "Accept" header' do
      before do
        Rack::MockRequest::DEFAULT_ENV['HTTP_ACCEPT'] =
          'application/vnd.atthemovies.v1'
      end

      after { Rack::MockRequest::DEFAULT_ENV.delete 'HTTP_ACCEPT' }

      specify do
        expect(get: '/cinemas.json').to route_to(controller: 'api/v1/cinemas',
                                                 action: 'index',
                                                 format: 'json')
      end

      specify do
        expect(get: '/cinemas').to route_to(controller: 'api/v1/cinemas',
                                            action: 'index')
      end
    end

    describe 'with specified format' do
      specify do
        expect(get: '/cinemas.json').to route_to(controller: 'api/v1/cinemas',
                                                 action: 'index',
                                                 format: 'json')
      end
    end
  end

  describe '#GET index' do
    let!(:cinema_1) { create(:cinema, latitude: 51.5, longitude: -0.5) }
    let!(:cinema_2) { create(:cinema, latitude: 52.5, longitude: -1.5) }
    let!(:cinema_3) { create(:cinema, latitude: 52.5, longitude: -0.5) }

    def get_index(params = {})
      request.env['HTTP_ACCEPT'] = 'application/vnd.atthemovies.v1'
      get :index, {}.merge(params)
    end

    describe 'successful' do
      before { get_index }

      it { is_expected.to respond_with :success }

      specify { expect(response.content_type).to eq 'application/json' }

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
            'brand', 'country', 'country_code', 'extended_address', 'latitude',
            'locality', 'longitude', 'postal_code', 'name', 'street_address',
            'url')
        end
      end
    end
  end
end
