require 'rails_helper'

describe Film do
  describe 'associations' do
    it { is_expected.to have_many :screenings }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'acts_as_url' do
    let(:film) { build(:film) }

    before do
      expect(film.url).to be_nil
      film.save!
    end

    it 'sets the url of the film' do
      expect(film.url).to_not be_nil
      expect(film.url).to eq(film.name.to_url)
    end
  end

  describe 'scope' do
    describe '.similar_to(name)' do
      let!(:film_1) { create(:film, name: 'Aliens') }
      let!(:film_2) { create(:film, name: 'Avengers: Age of Ultron') }
      let!(:film_3) { create(:film, name: 'Alien 3') }

      it 'returns films with similar names' do
        expect(Film.similar_to('Alien Resurrection')).to eq([film_1, film_3])
      end
    end

    describe '.whats_on' do
      let!(:film_1) { create(:film) }
      let!(:film_2) { create(:film) }
      let!(:film_3) { create(:film) }
      let!(:screening_1_1) { create(:screening, film: film_1) }
      let!(:screening_2_1) { create(:screening, film: film_2) }
      let!(:screening_2_2) { create(:screening, film: film_2) }

      it 'only returns films with screenings' do
        expect(Film.whats_on).not_to include(film_3)
      end

      it 'returns films in order of greatest number of screenings' do
        expect(Film.whats_on).to eq([film_2, film_1])
      end
    end
  end

  describe '#add_alternate_name(name)' do
    subject(:add_alternate_name) { film.add_alternate_name(name) }

    let!(:film) { create :film }
    let(:name)  { 'Extra Name' }

    it 'joins names into primary film' do
      add_alternate_name
      expect(film.reload.alternate_names).to include('Extra Name')
    end
  end

  describe '#hydrate(tmdb_movie)' do
    subject(:hydrate) { film.hydrate(tmdb_movie) }

    let(:film)       { build :film }
    let(:tmdb_movie) do
      instance_double(TmdbMovie, imdb_number: 1234567,
                                 overview: 'overview',
                                 runtime: 106,
                                 tagline: 'tagline')
    end

    it 'sets imdb_identifier' do
      expect { hydrate }.to change(film, :imdb_identifier).to('1234567')
    end
    it 'sets overview' do
      expect { hydrate }.to change(film, :overview).to('overview')
    end
    it 'sets runtime' do
      expect { hydrate }.to change(film, :runtime).to(106)
    end
    it 'sets tagline' do
      expect { hydrate }.to change(film, :tagline).to('tagline')
    end
  end

  describe '#merge(merge_id)' do
    subject(:merge) { film.merge(film_to_merge) }

    let!(:film)               { create :film }
    let!(:screening)          { create :screening, film: film }
    let!(:film_to_merge)      { create :film, name: 'Alien' }
    let!(:screening_to_merge) { create :screening, film: film_to_merge }

    it 'merges film' do
      expect { merge }.to change(Film, :count).from(2).to(1)
    end
    it 'assigns screenings to merged film' do
      merge
      expect(film.screenings).to include(screening_to_merge)
    end
    it 'joins names into primary film' do
      merge
      expect(film.reload.alternate_names).to include('Alien')
    end
  end

  describe '#set_backdrop_source(uri)' do
    subject(:set_backdrop_source) { film.set_backdrop_source(uri) }

    let(:film) { create :film }
    let(:uri) { URI('https://image.tmdb.org/t/p/original/filenameforbackdrop.jpg') }

    it 'sets the source uri' do
      set_backdrop_source
      expect(film.reload.backdrop_source_uri).to eq(uri.to_s)
    end
    it 'saves the film object' do
      set_backdrop_source
      expect(film).to be_persisted
    end

    it 'enqueues a job to store the film' do
      expect(FilmBackdropStorerJob).to receive(:enqueue).with(film_id: film.id)
      set_backdrop_source
    end
  end

  describe '#set_poster_source(uri)' do
    subject(:set_poster_source) { film.set_poster_source(uri) }

    let(:film) { create :film }
    let(:uri) { URI('https://image.tmdb.org/t/p/original/filenameforbackdrop.jpg') }

    it 'sets the source uri' do
      set_poster_source
      expect(film.reload.poster_source_uri).to eq(uri.to_s)
    end
    it 'saves the film object' do
      set_poster_source
      expect(film).to be_persisted
    end

    it 'enqueues a job to store the film' do
      expect(FilmPosterStorerJob).to receive(:enqueue).with(film_id: film.id)
      set_poster_source
    end
  end

  describe '#set_possibles(array)' do
    let(:film) { build :film }
    let(:args) { [123, 322, 456] }

    before { film.set_possibles(args) }

    it 'sets the tmdb_possibles array (converts to strings)' do
      expect(film.reload.tmdb_possibles).to eq(args.map(&:to_s))
    end
  end

  describe '#to_param' do
    subject { film.to_param }

    let!(:film) { build(:film, url: 'will-be-name-if-saved') }

    it { is_expected.to be_a(String) }
    it { is_expected.to eq("#{film.id}-#{film.url}") }
  end
end
