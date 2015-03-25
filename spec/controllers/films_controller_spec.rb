require 'rails_helper'

describe FilmsController do
  include BasicAuthHelper

  render_views

  describe 'routes' do
    specify do
      expect(get: '/films').to route_to(
        controller: 'films',
        action: 'index'
      )
    end
    specify do
      expect(get: '/films?q=2001').to route_to(
        controller: 'films',
        action: 'index',
        q: '2001'
      )
    end
    specify do
      expect(get: '/films/triage').to route_to(
        controller: 'films',
        action: 'triage'
      )
    end
    specify do
      expect(get: '/films/the-dark-knight').to route_to(
        controller: 'films',
        action: 'show',
        id: 'the-dark-knight'
      )
    end
    specify do
      expect(get: '/films/the-dark-knight.json').to route_to(
        controller: 'films',
        action: 'show',
        id: 'the-dark-knight',
        format: 'json'
      )
    end
    specify do
      expect(get: '/films/uuid/edit').to route_to(
        controller: 'films',
        action: 'edit',
        id: 'uuid'
      )
    end
    specify do
      expect(put: '/films/uuid/merge?merge=another_uuid').to route_to(
        controller: 'films',
        action: 'merge',
        id: 'uuid',
        merge: 'another_uuid'
      )
    end
    specify do
      expect(put: '/films/uuid').to route_to(
        controller: 'films',
        action: 'update',
        id: 'uuid'
      )
    end
  end

  describe 'GET #edit' do
    let!(:film) { create :film }

    def do_request(params = {})
      get :edit, { id: film.id }.merge(params)
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before do
        http_login
        do_request
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:edit) }
      specify { expect(assigns(:similar_films)).not_to be_nil }
    end
  end

  describe 'GET #index' do
    let(:films) { [create(:film)] }

    def do_request(params = {})
      get :index, {}.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before do
          expect(Film).to receive(:whats_on).and_return(films)
          do_request
        end

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:films)).to be_present }
        it { is_expected.to render_template 'index' }
      end

      describe 'with query' do
        before do
          expect(Film).to receive(:similar_to).with('boom').and_return(films)
          do_request(q: 'boom')
        end

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:films)).to be_present }
        it { is_expected.to render_template 'index' }
      end
    end
  end

  describe 'PUT #merge' do
    let!(:film)          { create :film }
    let!(:film_to_merge) { create :film }

    def do_request(params = {})
      request.env["HTTP_REFERER"] = 'back'
      put :merge, { id: film.id, other_id: film_to_merge.id }.merge(params)
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before do
        http_login
        expect(Films::Merge).to receive(:perform_now)
          .with(film, film_to_merge)
        do_request
      end

      it { is_expected.to respond_with(:redirect) }
      it { is_expected.to redirect_to('back') }
    end
  end

  describe 'GET #show' do
    let!(:film) { create :film }

    def do_request(params = {})
      get :show, { id: film.url }.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { do_request }

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:film)).to be_present }
        it { is_expected.to render_template 'show' }
      end
    end

    describe 'JSON' do
      describe 'successful' do
        before { do_request(format: 'json') }

        it { is_expected.to respond_with :success }

        it 'assigns film for the view' do
          expect(assigns(:film)).to be_present
        end

        it 'has root key of films' do
          expect(JSON.parse(response.body).keys).to eq(['films'])
        end

        it 'includes correct keys for the films' do
          JSON.parse(response.body)['films'].each do |film|
            expect(film.keys).to include('id', 'name')
          end
        end
      end
    end
  end

  describe 'GET #triage' do
    let!(:film_1) { create :film }
    let!(:film_2) { create :film }

    def do_request(params = {})
      get :triage, {}.merge(params)
    end

    describe 'HTML' do
      describe 'successful' do
        before { do_request }

        it { is_expected.to respond_with :success }
        specify { expect(assigns(:films)).to be_present }
        it { is_expected.to render_template 'triage' }
      end
    end
  end

  describe 'PUT #update' do
    let!(:film) { create :film, name: 'Alien' }

    def do_request(params = {})
      request.env["HTTP_REFERER"] = 'back'
      put :update, { id: film }.merge(params)
    end

    include_examples 'authenticated'

    context 'with authentication' do
      context 'with normal form submission' do
        before do
          http_login
          do_request(film: attributes_for(:film))
        end

        it { is_expected.to respond_with(:redirect) }
        it { is_expected.to redirect_to('back') }
        it 'stores the old name of the film' do
          expect(film.reload.alternate_names).to include('Alien')
        end
        it 'changes the film' do
          expect(film.reload.name).not_to eq('Alien')
        end
      end

      context 'with :add_information param to true' do
        before do
          http_login
          do_request(film: { information_added: true })
        end

        it { is_expected.to respond_with(:redirect) }
        it { is_expected.to redirect_to('back') }
        it 'adds the passed name into the film' do
          expect(film.reload.information_added).to eq(true)
        end
      end

      context 'with :alternate_name param' do
        before do
          http_login
          do_request(alternate_name: 'Aliens')
        end

        it { is_expected.to respond_with(:redirect) }
        it { is_expected.to redirect_to('back') }
        it 'adds the passed name into the film' do
          expect(film.reload.alternate_names).to include('Aliens')
        end
      end
    end
  end
end
