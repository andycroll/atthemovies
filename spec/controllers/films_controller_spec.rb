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
      expect( get: '/films/the-dark-knight' ).to route_to(
        controller: 'films',
        action: 'show',
        id: 'the-dark-knight'
      )
    }
    specify {
      expect( get: '/films/the-dark-knight.json' ).to route_to(
        controller: 'films',
        action: 'show',
        id: 'the-dark-knight',
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
      get :show, { id: id }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        let(:id) { film.url }
        before { get_show }

        it { should respond_with :success }
        specify { expect(assigns(:film)).to be_present }
        it { should render_template 'show' }
      end
    end

    describe 'JSON' do
      render_views

      describe 'successful' do
        let(:id) { film.url }
        before { get_show({ format: 'json' }) }

        it { should respond_with :success }
        specify { expect(assigns(:film)).to be_present }
        it 'should include correct keys' do
          JSON.parse(response.body).keys.should include(
            'name',
            'poster', 'backdrop'
          )
        end
      end
    end
  end
end
