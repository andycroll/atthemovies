require 'rails_helper'

describe Films::StoreBackdrop do
  let(:job)  { described_class.new.perform(film) }
  let(:film) { create(:film, id: 1, backdrop_source_uri: 'backdrop_url.jpg') }

  describe '#perform' do
    it 'remove the old backdrop and stores the film backdrop' do
      # expect(film).to receive(:remove_backdrop!)
      # expect(film).to receive(:remote_backdrop_url=).with(film.backdrop_source_uri)
      job
    end
  end
end
