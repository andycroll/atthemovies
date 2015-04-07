require 'rails_helper'

describe Films::FetchExternalIds do
  let(:get_tmdb_ids) { described_class.new.perform(film) }
  let(:film)         { create(:film, id: 1, name: 'Batman') }

  describe '#perform' do
    before do
      expect(ExternalFilm).to receive(:find).
        with(film.name).and_return(tmdb_response)
    end

    context 'multiple results' do
      let(:tmdb_movie_1) do
        instance_double(ExternalFilm,
                        tmdb_id:        123,
                        title_and_year: 'One (2011)')
      end
      let(:tmdb_movie_2) do
        instance_double(ExternalFilm,
                        tmdb_id:        456,
                        title_and_year: 'Two (2012)')
      end
      let(:tmdb_movie_3) do
        instance_double(ExternalFilm,
                        tmdb_id:        789,
                        title_and_year: 'Three (2013)')
      end
      let(:tmdb_response) do
        [tmdb_movie_1, tmdb_movie_2, tmdb_movie_3]
      end

      it 'queries themoviedb and sets films possibles' do
        expect(film).to receive(:update_possibles)
          .with([123, 456, 789]).and_return(true)

        get_tmdb_ids
      end
    end

    context 'single result' do
      let(:tmdb_response) do
        [
          instance_double(ExternalFilm,
                          tmdb_id:        123,
                          title:          'One',
                          title_and_year: 'One (2011)')
        ]
      end

      it 'queries themoviedb and sets films possibles' do
        expect(film).to receive(:update_possibles).with([123]).and_return(true)

        get_tmdb_ids
      end
    end

    context 'single result (with same name)' do
      let(:tmdb_response) do
        [
          instance_double(ExternalFilm,
                          tmdb_id:        123,
                          title:          'Batman',
                          title_and_year: 'Batman (1989)')
        ]
      end

      before do
        expect(Films::FetchExternalInformation).to receive(:perform_now).
          with(film).
          and_return(true)
      end

      it 'sets films id possibles' do
          expect { get_tmdb_ids }.to change(film, :tmdb_possibles).to(['123'])
      end

      it 'queries themoviedb and sets film id' do
        expect { get_tmdb_ids }.to change(film, :tmdb_identifier).to(123)
      end
    end
  end
end
