require 'spec_helper'

describe CinemasController do
  render_views

  describe 'routes' do
    specify {
      expect( get: '/cinemas/odeon-brighton' ).to route_to(
        controller: 'cinemas',
        action: 'show',
        id: 'odeon-brighton'
      )
    }
    specify {
      expect( get: '/cinemas/odeon-brighton.json' ).to route_to(
        controller: 'cinemas',
        action: 'show',
        id: 'odeon-brighton',
        format: 'json'
      )
    }
  end

  describe '#GET show' do
    let!(:cinema) { create :cinema }

    def get_show(params={})
      get :show, { id: id }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        let(:id) { cinema.url }
        before { get_show }

        it { should respond_with :success }
        specify { expect(assigns(:cinema)).to be_present }
        it { should render_template 'show' }
      end
    end

    describe 'JSON' do
      describe 'successful' do
        let(:id) { cinema.url }
        before { get_show({ format: 'json' }) }

        it { should respond_with :success }
        specify { expect(assigns(:cinema)).to be_present }
        it 'should include correct keys' do
          JSON.parse(response.body).keys.should include(
            'name',
            'latitude', 'longitude'
          )
        end
      end
    end
  end
end
