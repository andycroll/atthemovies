require 'rails_helper'

describe PagesController do
  describe 'routes' do
    specify {
      expect( get: '/' ).to route_to(
        controller: 'pages',
        action: 'home'
      )
    }
  end

  describe '#GET home' do
    def get_home(params={})
      get :home, {}.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before do
          get_home
        end

        it { is_expected.to respond_with :success }
        it { is_expected.to render_template 'home' }
      end
    end
  end
end
