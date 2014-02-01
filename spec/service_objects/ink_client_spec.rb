require 'spec_helper'

describe InkClient do
  let(:ink_client) { InkClient.new(options) }

  before do
    WebMock.disable_net_connect!
    ENV['API_INK_KEY'] = 'ink'
  end

  describe '.new' do
    let(:options) { { uri: URI(uri) } }

    context 'with ink uri' do
      let(:uri) { 'https://www.filepicker.io/api/file/N49i6hPRBeropWnCWOLw' }

      it 'sets handle' do
        expect(ink_client.handle).to eq('N49i6hPRBeropWnCWOLw')
      end
    end

    context 'with normal uri' do
      let(:uri) { 'http://www.google.com/images/srpr/logo11w.png' }

      it 'does not set handle' do
        expect(ink_client.handle).to be_nil
      end
    end
  end

  describe '#delete!' do
    subject(:delete!) { ink_client.delete! }

    context 'with ink uri' do
      let(:uri)      { 'https://www.filepicker.io/api/file/N49i6hPRBeropWnCWOLw' }
      let(:options)  { { uri: URI(uri) } }
      let(:response) { Rails.root.join('spec', 'fixtures', 'ink', 'store_success.json').read }

      it 'returns an ink uri' do
        ink_delete = stub_request(:delete, 'https://www.filepicker.io/api/file/N49i6hPRBeropWnCWOLw?key=ink').
          with(body: nil).
          to_return( status: 200, body: '', headers: {} )

        expect(delete!).to eq(true)
        expect(ink_client.handle).to eq(nil)
        ink_delete.should have_been_requested
      end
    end

    context 'with normal uri' do
      let(:uri)     { 'http://www.google.com/images/srpr/logo11w.png' }
      let(:options) { { uri: URI(uri) } }

      it { should be_nil }
    end
  end

  describe '#store!' do
    subject(:store!) { ink_client.store! }

    context 'with normal uri' do
      let(:uri)      { 'http://www.google.com/images/srpr/logo11w.png' }
      let(:options)  { { uri: URI(uri) } }
      let(:response) { Rails.root.join('spec', 'fixtures', 'ink', 'store_success.json').read }

      it 'returns an ink uri' do
        ink_store = stub_request(:post, 'http://www.filepicker.io/api/store/S3?key=ink').
          with(body: "url=#{CGI.escape(uri)}").
          to_return( status: 200, body: response, headers: {} )

        expect(store!).to eq(true)
        expect(ink_client.handle).to eq('N49i6hPRBeropWnCWOLw')
        ink_store.should have_been_requested
      end
    end

    context 'with ink uri' do
      let(:uri)     { 'https://www.filepicker.io/api/file/N49i6hPRBeropWnCWOLw' }
      let(:options) { { uri: URI(uri) } }

      it { should be_nil }
    end
  end

  def encode(hash)
    hash.collect do |key,val|
      "#{URI.escape(key.to_s)}=#{URI.escape(val)}"
    end.join('&')
  end
end
