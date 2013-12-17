require 'spec_helper'

describe CinemasController do
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
    def get_show
      get :show, { id: id }.merge(params)
    end

    describe 'JSON' do
      let(:params) { { format: 'json' } }

      describe 'successful' do
        let(:cinema) { create :cinema }
        let(:id) { cinema.url }
        before { get_show }
        it { should respond_with :success }
      end
    end
  end
end
