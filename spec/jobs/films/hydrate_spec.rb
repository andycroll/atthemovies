require 'rails_helper'

describe Films::Hydrate do
  let(:job)           { described_class.new.perform(film) }
  let(:tmdb_movie)    { instance_double(ExternalFilm, poster: tmdb_poster, backdrop: tmdb_backdrop) }
  let(:tmdb_poster)   { instance_double(ExternalFilm::Poster, uri: URI(Faker::Internet.url)) }
  let(:tmdb_backdrop) { instance_double(ExternalFilm::Backdrop, uri: URI(Faker::Internet.url)) }

  describe '#perform' do
    context 'with film with tmdb id and no data' do
      let(:film) { create(:film, tmdb_identifier: 2345) }

      before do
        expect(ExternalFilm).to receive(:new).with(film.tmdb_identifier).and_return(tmdb_movie)
      end

      it 'changes the film data' do
        expect(film).to receive(:hydrate).with(tmdb_movie)
        expect(film).to receive(:set_backdrop_source).with(tmdb_backdrop.uri)
        expect(film).to receive(:set_poster_source).with(tmdb_poster.uri)
        job
      end
    end

    context 'with film with blank tmdb id' do
      let(:film) { create(:film, tmdb_identifier: nil) }

      before do
        expect(ExternalFilm).to_not receive(:new)
      end

      it 'does not change the film' do
        expect(film).to_not receive(:hydrate)
        expect(film).to_not receive(:set_backdrop_source)
        expect(film).to_not receive(:set_poster_source)
        job
      end
    end
  end
end
