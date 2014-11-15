require 'rails_helper'

describe MovieInformationImporter do
  describe '#get_ids' do
    subject(:perform) { described_class.new.get_ids }

    let(:film_1) { instance_double('Film', id: rand(999)) }
    let(:film_2) { instance_double('Film', id: rand(999)) }

    it 'creates jobs to find TMDB ids' do
      expect(Film).to receive(:no_tmdb_details).and_return([film_1, film_2])

      expect(GetTmdbMovieIdsForFilmJob).to receive(:enqueue)
        .with(film_id: film_1.id)
      expect(GetTmdbMovieIdsForFilmJob).to receive(:enqueue)
        .with(film_id: film_2.id)

      perform
    end
  end
end
