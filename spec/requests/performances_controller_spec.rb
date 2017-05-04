# frozen_string_literal: true
require 'rails_helper'

describe PerformancesController, type: :request do
  describe 'GET index' do
    let(:base_url) { "/cinemas/#{cinema.to_param}/performances/#{2.days.from_now.strftime('%Y-%m-%d')}" }

    let(:cinema) { create :cinema }

    def do_request(url: base_url, headers: {}, params: {})
      get url, headers: headers, params: params
    end

    describe 'no date' do
      before { do_request(url: "/cinemas/#{cinema.to_param}/performances") }

      it 'redirects to todays performances' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(dated_cinema_performances_path(cinema, when: 'today'))
      end
    end

    describe 'successful, date "today"' do
      let!(:performance_1) { create :performance, cinema: cinema, starting_at: 10.minutes.from_now }
      let!(:performance_2) { create :performance, cinema: cinema, starting_at: 10.minutes.from_now }
      let!(:performance_other_cinema) { create :performance, starting_at: 10.minutes.from_now }

      before do
        do_request(url: "/cinemas/#{cinema.to_param}/performances/today")
      end

      it "shows today's performances" do
        expect(response).to have_http_status(:success)

        expect(response.body).to include(Date.today.to_s(:long))
        expect(response.body).to include(performance_1.film.name)
        expect(response.body).to include(performance_1.starting_at.utc.strftime('%H:%M'))
        expect(response.body).to include(performance_2.film.name)
        expect(response.body).to include(performance_2.starting_at.utc.strftime('%H:%M'))
        expect(response.body).not_to include(performance_other_cinema.film.name)
      end
    end

    describe 'successful, date "tomorrow"' do
      let!(:performance_1) { create :performance, cinema: cinema, starting_at: 1.day.from_now }
      let!(:performance_2) { create :performance, cinema: cinema, starting_at: 1.day.from_now }
      let!(:performance_today) { create :performance, cinema: cinema, starting_at: 10.minutes.from_now }
      let!(:performance_other_cinema) { create :performance, starting_at: 1.day.from_now }

      before do
        do_request(url: "/cinemas/#{cinema.to_param}/performances/tomorrow")
      end

      it "shows tomrrow's performances" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(Date.tomorrow.to_s(:long))
        expect(response.body).to include(performance_1.film.name)
        expect(response.body).to include(performance_1.starting_at.utc.strftime('%H:%M'))
        expect(response.body).to include(performance_2.film.name)
        expect(response.body).to include(performance_2.starting_at.utc.strftime('%H:%M'))
        expect(response.body).not_to include(performance_other_cinema.film.name)
        expect(response.body).not_to include(performance_today.film.name)
      end
    end

    describe 'successful, date "YYYY-MM-DD"' do
      let(:num) { rand(2..7) }

      let!(:performance_1) { create :performance, cinema: cinema, starting_at: num.days.from_now }
      let!(:performance_2) { create :performance, cinema: cinema, starting_at: num.days.from_now }
      let!(:performance_today) { create :performance, cinema: cinema, starting_at: 10.minutes.from_now }
      let!(:performance_tomorrow) { create :performance, cinema: cinema, starting_at: 1.day.from_now }
      let!(:performance_day_after) { create :performance, cinema: cinema, starting_at: (num+1).days.from_now }

      before do
        do_request(url: "/cinemas/#{cinema.to_param}/performances/#{num.days.from_now.strftime('%Y-%m-%d')}")
      end

      it "shows correct day's performances" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include(num.days.from_now.to_date.to_s(:long))
        expect(response.body).to include(performance_1.film.name)
        expect(response.body).to include(performance_1.starting_at.utc.strftime('%H:%M'))
        expect(response.body).to include(performance_2.film.name)
        expect(response.body).to include(performance_2.starting_at.utc.strftime('%H:%M'))
        expect(response.body).not_to include(performance_today.film.name)
        expect(response.body).not_to include(performance_tomorrow.film.name)
        expect(response.body).not_to include(performance_day_after.film.name)
      end
    end
  end
end
