# frozen_string_literal: true
RSpec.shared_examples 'application/json' do
  describe 'with json "Accept" header' do
    it 'renders JSON' do
      do_request(headers: { 'ACCEPT' => 'application/json' })
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe 'with application specific "Accept" header' do
    it 'renders JSON' do
      do_request(headers: { 'ACCEPT' => 'application/vnd.atthemovies.v1' })
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/json'
    end
  end
end

RSpec.shared_examples 'authenticated' do
  context 'without authentication' do
    before do
      do_request(headers: { 'Authorized' => credentials(u: 'not', pw: 'pass') })
    end

    it 'rejects' do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
