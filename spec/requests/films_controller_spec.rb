require 'rails_helper'

describe FilmsController, type: :request do
  include BasicAuthHelper
  include HtmlEntityHelper

  let(:auth_headers) { { 'Authorization' => credentials } }

  describe '#GET edit' do
    let(:base_url) { "/films/#{film.id}/edit" }

    let!(:film) { create :film }

    def do_request(url: base_url, headers: auth_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before { do_request }

      it 'includes title & form' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include("Edit #{film.name}")
        expect(response.body).to include('<form')
      end
    end
  end

  describe 'GET #index' do
    let(:base_url) { '/films' }

    let!(:film_1) { create(:film) }
    let!(:film_2) { create(:film) }

    before do
      create(:performance, film: film_1)
      create(:performance, film: film_2)
      create(:performance, film: film_2)
    end

    def do_request(url: base_url, headers: {}, params: {})
      get url, headers: headers, params: params
    end

    describe 'successful' do
      before { do_request }

      it 'includes title & films' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include('Films')
        expect(response.body).to include(h film_1.name)
        expect(response.body).to include(h film_2.name)

        expect(response.body).to include('<input type="text" name="q"')
      end
    end

    describe 'successful, with query' do
      let(:searchstring) { film_1.name.split(' ')[0] }

      before { do_request(url: "/films?q=#{searchstring}") }

      it 'includes title & matched films' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include('Films')
        expect(response.body).to include(h film_1.name)
        expect(response.body).not_to include(h film_2.name)
      end
    end
  end

  describe 'PUT #merge' do
    let(:base_url) { "/films/#{film_1.id}/merge" }

    let!(:film_1) { create :film }
    let!(:film_2) { create :film }

    def do_request(url: base_url,
                   headers: auth_headers.merge('HTTP_REFERER' => 'back'),
                   params: { other_id: film_2.id })
      put url, headers: headers, params: params
    end

    include_examples 'authenticated'

    context 'with authentication' do
      it 'merges film 1 into film 2' do
        expect { do_request }.to change { Film.count }.by(-1)
        expect(Film.first.name).to eq(film_2.name)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('back')
      end
    end
  end

  describe 'GET #show' do
    let(:base_url) { "/films/#{film.url}" }

    let!(:film) { create :film }

    def do_request(url: base_url, headers: {}, params: {})
      get url, headers: headers, params: params
    end

    describe 'successful' do
      before { do_request }

      it 'includes title' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include(h film.name)
      end
    end
  end

  describe 'GET #triage' do
    let(:base_url) { '/triage' }

    let!(:film_1) { create(:film, name: 'Alien') }
    let!(:film_2) { create(:film, name: 'Fight Club') }

    before do
      create(:performance, film: film_1)
      create(:performance, film: film_2)
      create(:performance, film: film_2)
    end

    def do_request(url: base_url, headers: auth_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'authenticated'

    describe 'successful' do
      before { do_request }

      it 'includes title & films' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include('Triage')
        expect(response.body).to include(h film_1.name)
        expect(response.body).to include(h film_2.name)

        expect(response.body).to include('<input type="text" name="q"')
      end
    end

    describe 'successful, with query' do
      before { do_request(url: '/triage?q=alien') }

      it 'includes title & matched films' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include('Triage')
        expect(response.body).to include(h film_1.name)
        expect(response.body).not_to include(h film_2.name)
      end
    end
  end

  describe 'PUT #update' do
    let(:base_url) { "/films/#{film.id}" }

    let!(:film) { create :film, name: 'Alien' }

    def do_request(url: base_url,
                   headers: auth_headers.merge('HTTP_REFERER' => 'back'),
                   params: { film: attributes_for(:film) })
      put url, headers: headers, params: params
    end

    include_examples 'authenticated'

    context 'with authentication' do
      it 'updates film attributes' do
        expect { do_request }.not_to change { Film.count }

        expect(Film.first.name).not_to eq('Alien')
        expect(Film.first.alternate_names).to include('Alien')

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('back')
      end
    end

    context 'with :alternate_name param' do
      before { do_request(params: { alternate_name: 'Aliens' }) }

      it 'adds alt name' do
        expect(film.reload.alternate_names).to include('Aliens')

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('back')
      end
    end
  end
end
