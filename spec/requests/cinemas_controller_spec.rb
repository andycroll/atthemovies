require 'rails_helper'

describe CinemasController, type: :request do
  include BasicAuthHelper
  include HtmlEntityHelper

  let(:auth_headers) { { 'Authorization' => credentials } }

  describe '#GET edit' do
    let(:base_url) { "/cinemas/#{cinema.to_param}/edit" }

    let!(:cinema) { create :cinema }

    def do_request(url: base_url, headers: auth_headers, params: {})
      get url, headers: headers, params: params
    end

    include_examples 'authenticated'

    context 'with authentication' do
      before { do_request }

      it 'includes title & form' do
        expect(response).to have_http_status(:success)

        expect(response.body).to include("Edit #{cinema.name}")
        expect(response.body).to include('<form')
      end

      it 'includes body classes and js init' do
        expect(response.body).to include('<body id="cinemas-edit" class="cinemas edit">')
        expect(response.body).to include('atthemovies.pages.cinemas.initEdit();')
        expect(response.body).to include('atthemovies.pages.cinemas.init();')
      end
    end
  end

  describe '#GET index' do
    let(:base_url) { '/cinemas' }

    let!(:cinema_1) { create(:cinema, latitude: 51.5, longitude: -0.5) }
    let!(:cinema_2) { create(:cinema, latitude: 52.5, longitude: -1.5) }
    let!(:cinema_3) { create(:cinema, latitude: 52.5, longitude: -0.5) }

    def do_request(url: base_url, headers: {}, params: {})
      get url, headers: headers, params: params
    end

    describe 'HTML' do
      describe 'successful' do
        before { do_request }

        it 'includes title & form' do
          expect(response).to have_http_status(:success)

          expect(response.body).to include(h cinema_1.name)
          expect(response.body).to include(cinema_path(cinema_1))
          expect(response.body).to include(h(cinema_2.name))
          expect(response.body).to include(cinema_path(cinema_2))
          expect(response.body).to include(h(cinema_3.name))
          expect(response.body).to include(cinema_path(cinema_3))
        end
      end

      describe 'with ?near=lat,lng' do
        before { do_request(url: '/cinemas?near=50,0') }

        it 'includes title & form' do
          expect(response).to have_http_status(:success)

          expect(response.body).to match(/\d\.\d{2}m/) # distance
          expect(response.body).to include(h(cinema_1.name))
          expect(response.body).to include(cinema_path(cinema_1))
          expect(response.body).to include(h(cinema_2.name))
          expect(response.body).to include(cinema_path(cinema_2))
          expect(response.body).to include(h(cinema_3.name))
          expect(response.body).to include(cinema_path(cinema_3))
        end
      end
    end
  end

  describe '#GET show' do
    let(:base_url) { "/cinemas/#{cinema.to_param}" }

    let!(:cinema) { create :cinema }

    def do_request(url: base_url, headers: {}, params: {})
      get url, headers: headers, params: params
    end

    before { do_request }

    it 'includes cinema info and links to performances' do
      expect(response).to have_http_status(:success)

      expect(response.body).to include(h(cinema.name))
      expect(response.body).to include('Today')
      expect(response.body).to include(dated_cinema_performances_path(cinema, when: 'today'))
      expect(response.body).to include('Tomorrow')
      expect(response.body).to include(dated_cinema_performances_path(cinema, when: 'tomorrow'))
      expect(response.body).to include(dated_cinema_performances_path(cinema, when: 3.days.from_now.strftime('%Y-%m-%d')))
      expect(response.body).to include(dated_cinema_performances_path(cinema, when: 14.days.from_now.strftime('%Y-%m-%d')))
    end
  end

  describe '#PUT update' do
    let(:base_url) { "/cinemas/#{cinema.to_param}" }
    let(:base_params) { { cinema: attributes_for(:cinema) } }

    let!(:cinema) { create :cinema, name: 'Cinema' }

    def do_request(url: base_url, headers: auth_headers, params: base_params)
      put url, headers: headers, params: params
    end

    include_examples 'authenticated'

    context 'with authentication' do
      it 'changes cinema attributes and redirects' do
        expect { do_request }.to change { cinema.reload.name }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(cinemas_path)
      end
    end
  end
end
