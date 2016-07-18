require 'rails_helper'

describe Api::V1::Films::PerformancesController do
  render_views

  describe 'routes' do
    describe 'with http "Accept" header' do
      before do
        Rack::MockRequest::DEFAULT_ENV['HTTP_ACCEPT'] =
          'application/vnd.atthemovies.v1'
      end

      after { Rack::MockRequest::DEFAULT_ENV.delete 'HTTP_ACCEPT' }

      specify do
        expect(get: '/films/23/performances.json').to route_to(controller: 'api/v1/films/performances',
                                                                 action: 'index',
                                                                 format: 'json',
                                                                 film_id: '23')

        expect(get: '/films/23/performances').to route_to(controller: 'api/v1/films/performances',
                                                          action: 'index',
                                                          film_id: '23')
      end
    end

    describe 'with specified format' do
      specify do
        expect(get: '/films/23/performances.json').to route_to(controller: 'api/v1/films/performances',
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
    let!(:performance_other_date) { create(:performance, starting_at: 1.day.from_now) }

    def get_index(params = {})
      request.env['HTTP_ACCEPT'] = 'application/vnd.atthemovies.v1'
      get :index, { film_id: film.id }.merge(params)
    end

    describe 'successful' do
      before { get_index(date: 2.days.from_now.strftime('%Y%m%d')) }

      it { is_expected.to respond_with :success }

      specify { expect(response.content_type).to eq 'application/json' }

      it 'includes performances from that cinema on that day' do
        parsed = JSON.parse(response.body)
        expect(parsed['data'].count).to eq(2)
        performance_ids = parsed['data'].map { |c| c['id'] }
        expect(performance_ids).to include(performance_1.id)
        expect(performance_ids).to include(performance_2.id)
      end

      it 'does not include performances from other films or dates' do
        parsed = JSON.parse(response.body)
        performance_ids = parsed['data'].map { |c| c['id'] }
        expect(performance_ids).not_to include(performance_other_film.id)
        expect(performance_ids).not_to include(performance_other_date.id)
      end

      it 'includes full performance data, and relationships to film & cinema' do
        parsed = JSON.parse(response.body)
        parsed['data'].each do |c|
          expect(c['type']).to eq('performances')
          expect(c.keys).to contain_exactly('id', 'type', 'attributes', 'relationships')
          expect(c['attributes'].keys).to contain_exactly(
            'dimension', 'starting-at', 'variant')
          expect(c['relationships'].keys).to contain_exactly('cinema', 'film')
        end
      end
    end
  end
end
