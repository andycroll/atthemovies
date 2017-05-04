# frozen_string_literal: true
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

        it 'includes body js init' do
          expect(response.body).to include('<body data-js-controller="pages" data-js-action="Home">')
        end
      end
    end
  end
end
