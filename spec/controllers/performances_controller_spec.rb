require 'rails_helper'

describe PerformancesController do
  render_views

  describe 'routes' do
    specify do
      expect(get: '/cinemas/odeon-brighton/performances').to route_to(
        controller: 'performances',
        action: 'index',
        cinema_id: 'odeon-brighton'
      )
    end

    specify do
      expect(get: '/cinemas/odeon-brighton/performances/today').to route_to(
        controller: 'performances',
        action: 'index',
        cinema_id: 'odeon-brighton',
        when: 'today'
      )
    end
  end

  describe 'GET index' do
    let(:cinema) { create :cinema }

    def do_request(params = {})
      get :index, { cinema_id: cinema.to_param }.merge(params)
    end

    describe 'no date' do
      before { do_request }

      it { is_expected.to respond_with :redirect }
      specify do
        is_expected.to redirect_to dated_cinema_performances_path(cinema,
                                                                  when: 'today')
      end
    end

    describe 'successful, date "today"' do
      before do
        2.times do
          create :performance, cinema: cinema, starting_at: 10.minutes.from_now
        end
        create :performance, starting_at: 10.minutes.from_now

        do_request(when: 'today')
      end

      it { is_expected.to respond_with :success }

      it 'assigns cinema' do
        expect(assigns(:cinema)).to eq(cinema)
      end

      it 'assigns performances in a grouper for the view' do
        expect(assigns(:performances)).to be_present
      end

      it 'only include performances from specified cinema' do
        expect(assigns(:performances).length).to eq(2)
        assigns(:performances).each do |perf|
          expect(perf.cinema).to eq(cinema)
        end
      end

      it { is_expected.to render_template 'index' }
    end

    describe 'successful, date "tomorrow"' do
      before do
        2.times do
          create :performance, cinema: cinema, starting_at: 1.day.from_now
        end
        create :performance, cinema: cinema, starting_at: 1.minute.from_now
        create :performance, starting_at: 1.day.from_now

        do_request(when: 'tomorrow')
      end

      it { is_expected.to respond_with :success }

      it 'assigns cinema' do
        expect(assigns(:cinema)).to eq(cinema)
      end

      it 'assigns performances in a grouper for the view' do
        expect(assigns(:performances)).to be_present
      end

      it 'only include performances from specified cinema' do
        expect(assigns(:performances).length).to eq(2)
        assigns(:performances).each do |perf|
          expect(perf.cinema).to eq(cinema)
          expect(perf.starting_at.to_date).to eq(Date.tomorrow)
        end
      end

      it { is_expected.to render_template 'index' }
    end

    describe 'successful, date "YYYY-MM-DD"' do
      let(:num) { rand(2..7) }

      before do
        2.times do
          create :performance, cinema: cinema, starting_at: num.days.from_now
        end
        create :performance, cinema: cinema, starting_at: 1.minute.from_now
        create :performance, starting_at: 1.day.from_now

        do_request(when: num.days.from_now.to_s('%Y-%m-%d'))
      end

      it { is_expected.to respond_with :success }

      it 'assigns cinema' do
        expect(assigns(:cinema)).to eq(cinema)
      end

      it 'assigns performances in a grouper for the view' do
        expect(assigns(:performances)).to be_present
      end

      it 'only include performances from specified cinema' do
        expect(assigns(:performances).length).to eq(2)
        assigns(:performances).each do |perf|
          expect(perf.cinema).to eq(cinema)
          expect(perf.starting_at.to_date).to eq(num.days.from_now.to_date)
        end
      end

      it { is_expected.to render_template 'index' }
    end
  end
end
