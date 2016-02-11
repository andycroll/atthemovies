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
  end

  describe 'GET index' do
    let(:cinema) { create :cinema }
    before do
      2.times { create :performance, cinema: cinema }
      create :performance
    end

    def do_request(params = {})
      get :index, { cinema_id: cinema.to_param }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { do_request }

        it { is_expected.to respond_with :success }

        it 'assigns cinema' do
          expect(assigns(:cinema)).to eq(cinema)
        end

        it 'assigns performances in a grouper for the view' do
          expect(assigns(:performances)).to be_present
          expect(assigns(:performances)).to be_a(PerformanceGrouper)
        end

        it 'only include performances from specified cinema' do
          expect(assigns(:performances).length).to eq(2)
          assigns(:performances).performances.each do |scr|
            expect(scr.cinema).to eq(cinema)
          end
        end

        it { is_expected.to render_template 'index' }
      end
    end
  end
end
