require 'rails_helper'

describe PagesController, type: :request do
  describe '#GET home' do
    def do_request
      get '/'
    end

    describe 'HTML' do
      describe 'successful' do
        before { do_request }

        it 'includes title & links' do
          expect(response).to have_http_status(:success)

          expect(response.body).to include('Cinemas')
          expect(response.body).to include(cinemas_path)
          expect(response.body).to include('Films')
          expect(response.body).to include(films_path)
        end

        it 'includes body classes and js init' do
          expect(response.body).to include('<body id="pages-home" class="pages home">')
          expect(response.body).to include('atthemovies.pages.pages.initHome();')
          expect(response.body).to include('atthemovies.pages.pages.init();')
        end
      end
    end
  end
end
