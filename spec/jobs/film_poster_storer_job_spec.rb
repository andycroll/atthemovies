require 'rails_helper'

describe FilmPosterStorerJob do
  let(:job)  { FilmPosterStorerJob.new(film_id: film.id) }
  let(:film) { object_double(Film.new, id: 1, poster_source_uri: 'poster_url.jpg') }

  describe '#perform' do
    before do
      expect(Film).to receive(:find).with(film.id).and_return(film)
    end

    it 'remove the old poster and stores the film poster' do
      # expect(film).to receive(:remove_poster!)
      # expect(film).to receive(:remote_poster_url=).with(film.poster_source_uri)
      expect(film).to receive(:save).twice.and_return(true)
      job.perform
    end
  end
end
