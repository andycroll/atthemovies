# frozen_string_literal: true
require 'rails_helper'

describe Api::V1::Cinemas::PerformancesController do
  describe '#GET index' do
    let(:base_url) { "/cinemas/#{cinema.id}/performances?date=#{2.days.from_now.strftime('%Y%m%d')}" }
    let(:base_headers) { { 'ACCEPT' => 'application/vnd.atthemovies.v1' } }

    let!(:cinema) { create(:cinema) }
    let!(:performance_1) { create(:performance, cinema: cinema ) }
    let!(:performance_2) { create(:performance, cinema: cinema) }
    let!(:performance_other_cinema) { create(:performance) }
    let!(:performance_other_date) { create(:performance, starting_at: 1.day.from_now) }

    def do_request(url: base_url, headers: base_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'application/json'

    describe 'with .json' do
      it 'renders JSON' do
        do_request(url: "/cinemas/#{cinema.id}/performances.json?date=#{2.days.from_now.strftime('%Y%m%d')}",
                   headers: {})
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json'
      end
    end

    describe 'with no date' do
      it 'fails' do
        expect { do_request(url: "/cinemas/#{cinema.id}/performances") }.to raise_error(ActionController::ParameterMissing)
      end
    end

    describe 'successful' do
      before { do_request }

      it 'includes performances from that cinema on that day' do
        parsed = JSON.parse(response.body)
        expect(parsed['data'].count).to eq(2)
        performance_ids = parsed['data'].map { |c| c['id'] }
        expect(performance_ids).to include(performance_1.id)
        expect(performance_ids).to include(performance_2.id)
      end

      it 'does not include performances from other cinemas or dates' do
        parsed = JSON.parse(response.body)
        performance_ids = parsed['data'].map { |c| c['id'] }
        expect(performance_ids).not_to include(performance_other_cinema.id)
        expect(performance_ids).not_to include(performance_other_date.id)
      end

      it 'includes full performance data, and relationsships to film & cinema' do
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
