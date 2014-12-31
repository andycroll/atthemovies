require 'rails_helper'

describe Films::GetTmdbIds do
  let(:get_tmdb_ids) { described_class.new.perform(film) }
  let(:film)         { create(:film, id: 1, name: 'Batman') }

  describe '#perform' do
    before do
      expect(Tmdb::Movie).to receive(:find).
        with(film.name).and_return(tmdb_response)
    end

    context 'multiple results' do
      let(:tmdb_response) do
        [
          instance_double(Tmdb::Movie, id: 123),
          instance_double(Tmdb::Movie, id: 456),
          instance_double(Tmdb::Movie, id: 789)
        ]
      end

      it 'queries themoviedb and sets films possibles' do
        expect(film).to receive(:update_possibles)
          .with([123, 456, 789]).and_return(true)

        get_tmdb_ids
      end
    end

    context 'single result' do
      let(:tmdb_response) { [instance_double(Tmdb::Movie, id: 123)] }

      it 'queries themoviedb and sets films possibles' do
        expect(film).to receive(:update_possibles)
          .with([123]).and_return(true)

        get_tmdb_ids
      end
    end
  end
end
