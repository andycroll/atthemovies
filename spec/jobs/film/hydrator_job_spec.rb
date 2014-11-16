require 'rails_helper'

describe Film::HydratorJob do
  let(:job)           { described_class.new(film_id: film.id) }
  let(:tmdb_movie)    { instance_double(TmdbMovie, poster: tmdb_poster, backdrop: tmdb_backdrop) }
  let(:tmdb_poster)   { instance_double(TmdbPoster, uri: URI(Faker::Internet.url)) }
  let(:tmdb_backdrop) { instance_double(TmdbBackdrop, uri: URI(Faker::Internet.url)) }

  describe '#perform' do
    before do
      expect(Film).to receive(:find).with(film.id).and_return(film)
    end

    context 'with film with tmdb id and no data' do
      let(:film) { object_double(Film.new, id: 1, tmdb_identifier: 2345) }

      before do
        expect(TmdbMovie).to receive(:new).with(film.tmdb_identifier).and_return(tmdb_movie)
      end

      it 'changes the film data' do
        expect(film).to receive(:hydrate).with(tmdb_movie)
        expect(film).to receive(:set_backdrop_source).with(tmdb_backdrop.uri)
        expect(film).to receive(:set_poster_source).with(tmdb_poster.uri)
        job.perform
      end
    end

    context 'with film with blank tmdb id' do
      let(:film) { object_double(Film.new, id: 1, tmdb_identifier: nil) }

      before do
        expect(TmdbMovie).to_not receive(:new)
      end

      it 'does not change the film' do
        expect(film).to_not receive(:hydrate)
        expect(film).to_not receive(:set_backdrop_source)
        expect(film).to_not receive(:set_poster_source)
        job.perform
      end
    end
  end
end
