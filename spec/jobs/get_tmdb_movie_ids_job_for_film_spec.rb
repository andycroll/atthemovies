require 'spec_helper'

describe GetTmdbMovieIdsForFilmJob do
  let(:job)  { GetTmdbMovieIdsForFilmJob.new(film_id: film.id) }
  let(:film) { create :film }

  describe '#perform' do
    before { expect(Film).to receive(:find).and_return(film) }

    context 'multiple results' do
      let(:tmdb_response) do
        [
          instance_double(Tmdb::Movie, id: 123),
          instance_double(Tmdb::Movie, id: 456),
          instance_double(Tmdb::Movie, id: 789)
        ]
      end

      it 'queries themoviedb and sets films possibles' do
        expect(Tmdb::Movie).to receive(:find).with(film.name).and_return(tmdb_response)
        expect(film).to receive(:set_possibles).with([123,456,789]).and_return(true)
        job.perform
      end
    end

    context 'single result' do
      let(:tmdb_response) { [instance_double(Tmdb::Movie, id: 123)] }

      it 'queries themoviedb and sets films possibles' do
        expect(Tmdb::Movie).to receive(:find).with(film.name).and_return(tmdb_response)
        expect(film).to receive(:set_possibles).with([123]).and_return(true)
        job.perform
      end
    end
  end
end
