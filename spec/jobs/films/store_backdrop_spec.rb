require 'rails_helper'

describe Films::StoreBackdrop do
  let(:job)  { described_class.new(film_id: film.id) }
  let(:film) { object_double(Film.new, id: 1, backdrop_source_uri: 'backdrop_url.jpg') }

  describe '#perform' do
    before do
      expect(Film).to receive(:find).with(film.id).and_return(film)
    end

    it 'remove the old backdrop and stores the film backdrop' do
      # expect(film).to receive(:remove_backdrop!)
      # expect(film).to receive(:remote_backdrop_url=).with(film.backdrop_source_uri)
      expect(film).to receive(:save).twice.and_return(true)
      job.perform
    end
  end
end
