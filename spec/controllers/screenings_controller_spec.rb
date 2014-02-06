require 'spec_helper'

describe ScreeningsController do
  render_views

  describe 'routes' do
    specify {
      expect( get: '/cinemas/1-odeon-brighton/screenings' ).to route_to(
        controller: 'screenings',
        action: 'index',
        cinema_id: '1-odeon-brighton'
      )
    }
    specify {
      expect( get: '/cinemas/1-odeon-brighton/screenings.json' ).to route_to(
        controller: 'screenings',
        action: 'index',
        cinema_id: '1-odeon-brighton',
        format: 'json'
      )
    }
  end

  describe 'GET index' do
    let(:cinema)     { create :cinema }
    before do
      2.times { create :screening, cinema: cinema }
      2.times { create :screening }
    end

    def get_index(params={})
      get :index, { cinema_id: cinema.to_param }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { get_index }

        it { should respond_with :success }

        it 'assigns cinema' do
          expect(assigns(:cinema)).to eq(cinema)
        end

        it 'assigns screenings for the view' do
          expect(assigns(:screenings)).to be_present
        end

        it 'only include screenings from specified cinema' do
          expect(assigns(:screenings).length).to eq(2)
          assigns(:screenings).each do |scr|
            expect(scr.cinema).to eq(cinema)
          end
        end

        it { should render_template 'index' }
      end
    end

    describe 'JSON' do
      describe 'successful' do
        before { get_index(format: 'json') }

        it { should respond_with :success }

        it 'assigns screenings for the view' do
          expect(assigns(:screenings)).to be_present
        end

        it 'only include screenings from specified cinema' do
          expect(assigns(:screenings).length).to eq(2)
          assigns(:screenings).each do |scr|
            expect(scr.cinema).to eq(cinema)
          end
        end

        it 'should route screenings key' do
          JSON.parse(response.body).keys.should eq(['screenings'])
        end

        it 'includes correct keys for the screenings' do
          JSON.parse(response.body)['screenings'].each do |scr|
            expect(scr.keys).to include('id', 'showing_at')
          end
        end
      end
    end
  end

end
