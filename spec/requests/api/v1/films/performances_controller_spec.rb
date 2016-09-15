require 'rails_helper'

describe Api::V1::Films::PerformancesController, type: :request do
  describe '#GET index' do
    let(:base_url) { "/films/#{film.id}/performances?date=#{2.days.from_now.strftime('%Y%m%d')}" }
    let(:base_headers) { { 'ACCEPT' => 'application/vnd.atthemovies.v1' } }

    let!(:film) { create(:film) }
    let!(:performance_1) { create(:performance, film: film ) }
    let!(:performance_2) { create(:performance, film: film) }
    let!(:performance_other_film) { create(:performance) }
    let!(:performance_other_date) { create(:performance, starting_at: 1.day.from_now) }

    def do_request(url: base_url, headers: base_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'application/json'

    describe 'with .json' do
      it 'renders JSON' do
        do_request(url: "/films/#{film.id}/performances.json?date=#{2.days.from_now.strftime('%Y%m%d')}",
                   headers: {})
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json'
      end
    end

    describe 'with no date' do
      it 'fails' do
        expect { do_request(url: "/films/#{film.id}/performances") }.to raise_error(ActionController::ParameterMissing)
      end
    end

    describe 'successful' do
      before do
        do_request(headers: { 'ACCEPT' => 'application/vnd.atthemovies.v1' })
      end

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
