require 'rails_helper'

describe CinemasController do
  include BasicAuthHelper

  render_views

  describe 'routes' do
    specify do
      expect(get: '/cinemas').to route_to(
        controller: 'cinemas',
        action: 'index'
      )
    end
    specify do
      expect(get: '/cinemas/odeon-brighton').to route_to(
        controller: 'cinemas',
        action: 'show',
        id: 'odeon-brighton'
      )
    end
    specify do
      expect(get: '/cinemas/odeon-brighton/edit').to route_to(
        controller: 'cinemas',
        action: 'edit',
        id: 'odeon-brighton'
      )
    end
    specify do
      expect(get: '/cinemas/odeon-brighton.json').to route_to(
        controller: 'cinemas',
        action: 'show',
        id: 'odeon-brighton',
        format: 'json'
      )
    end
  end

  describe '#GET edit' do
    let!(:cinema) { create :cinema }

    def do_request(params = {})
      get :edit, { id: cinema.to_param }.merge(params)
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before do
        http_login
        do_request
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:edit) }
      specify { expect(assigns(:cinema)).not_to be_nil }
    end
  end

  describe '#GET index' do
    let!(:cinema_1) { create(:cinema, latitude: 51.5, longitude: -0.5) }
    let!(:cinema_2) { create(:cinema, latitude: 52.5, longitude: -1.5) }
    let!(:cinema_3) { create(:cinema, latitude: 52.5, longitude: -0.5) }

    def get_index(params = {})
      get :index, {}.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { get_index }

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:cinemas)).to be_present }
        it { is_expected.to render_template 'index' }
      end

      describe 'with ?near=lat,lng' do
        before { get_index(near: '50,0') }

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:cinemas)).to be_present }
        it { is_expected.to render_template 'index' }
        it 'returns cinemas in order' do
          expect(assigns(:cinemas)).to eq([cinema_1, cinema_3, cinema_2])
        end
      end
    end
  end

  describe '#GET show' do
    let!(:cinema) { create :cinema }

    def get_show(params = {})
      get :show, { id: cinema.to_param }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { get_show }

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:cinema)).to be_present }
        it { is_expected.to render_template 'show' }
      end
    end

    describe 'JSON' do
      describe 'successful' do
        before { get_show(format: 'json') }

        it { is_expected.to respond_with :success }
        it 'has root key of cinemas' do
          expect(JSON.parse(response.body).keys).to eq(['cinemas'])
        end
        it 'includes correct keys for the cinemas' do
          JSON.parse(response.body)['cinemas'].each do |film|
            expect(film.keys).to include('id', 'name', 'latitude', 'longitude')
          end
        end
      end
    end
  end

  describe '#PUT update' do
    let!(:cinema) { create :cinema, name: 'Cinema' }

    def do_request(params = {})
      get :update, { id: cinema.to_param }.merge(params)
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before do
        http_login
        do_request(cinema: attributes_for(:cinema))
      end

      it { is_expected.to respond_with(:redirect) }
      it { is_expected.to redirect_to(cinemas_path) }
      it 'changes values' do
        expect(cinema.reload.name).not_to eq('Cinema')
      end
    end
  end
end
