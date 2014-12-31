require 'rails_helper'

describe Films::StorePoster do
  let(:job)  { described_class.new.perform(film) }
  let(:film) { create(:film, id: 1, poster_source_uri: 'poster_url.jpg') }

  describe '#perform' do
    it 'remove the old poster and stores the film poster' do
      # expect(film).to receive(:remove_poster!)
      # expect(film).to receive(:remote_poster_url=).with(film.poster_source_uri)
      job
    end
  end
end
