require 'rails_helper'

describe ImageUploader do
  describe '#store' do
    subject(:store) { described_class.new(args).store }

    let(:args) do
      {
        url:       'https://image.tmdb.org/t/p/original/nIQOgiHnAF9fnvqnOO0etd0YIb9.jpg',
        file_name: 'posters/chappie-2015/400x600'
      }
    end
    let(:dragonfly) { double(Dragonfly) }
    let(:dragonfly_job) { double('DragonflyJob') }

    before do
      expect(Dragonfly).to receive(:app) { dragonfly }
      expect(dragonfly).to receive(:fetch_url).with(args[:url]) { dragonfly_job }
      expect(dragonfly_job).to receive_message_chain(:thumb, :encode)
      expect(dragonfly_job).to receive(:store) { "#{args[:file_name]}.jpg" }
      expect(dragonfly).to receive(:remote_url_for).
        with("#{args[:file_name]}.jpg").
        and_return("http://cdn.com/#{args[:file_name]}.jpg")
    end


    it 'calls Dragonfly and returns http-less URL' do
      expect(subject).to eq("//cdn.com/#{args[:file_name]}.jpg")
    end
  end
end
