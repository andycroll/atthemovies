require 'spec_helper'

describe FilmsController do
  describe 'routes' do
    specify {
      expect( get: '/films' ).to route_to(
        controller: 'films',
        action: 'index'
      )
    }
    specify {
      expect( get: '/films/3-the-dark-knight' ).to route_to(
        controller: 'films',
        action: 'show',
        id: '3-the-dark-knight'
      )
    }
    specify {
      expect( get: '/films/3-the-dark-knight.json' ).to route_to(
        controller: 'films',
        action: 'show',
        id: '3-the-dark-knight',
        format: 'json'
      )
    }
  end

  describe '#GET index' do
    let(:films) { [instance_double(Film)] }

    def get_index(params={})
      get :index, {}.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before do
          expect(Film).to receive(:whats_on).and_return(films)
          get_index
        end

        it { should respond_with :success }
        specify { expect(assigns(:films)).to be_present }
        it { should render_template 'index' }
      end
    end
  end

  describe '#GET show' do
    let!(:film) { create :film }

    def get_show(params={})
      get :show, { id: film.to_param }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { get_show }

        it { should respond_with :success }
        specify { expect(assigns(:film)).to be_present }
        it { should render_template 'show' }
      end
    end

    describe 'JSON' do
      render_views

      describe 'successful' do
        before { get_show({ format: 'json' }) }

        it { should respond_with :success }
        specify { expect(assigns(:film)).to be_present }
        it 'should route films key' do
          JSON.parse(response.body).keys.should eq(['films'])
        end
        it 'includes correct keys for the films' do
          JSON.parse(response.body)['films'].each do |film|
            expect(film.keys).to include('id', 'name')
          end
        end
      end
    end
  end
end
