require 'rails_helper'

describe Film do
  describe 'associations' do
    it { is_expected.to have_many :screenings }
  end

  describe 'callbacks' do
    describe 'before update' do
      let!(:film) { create(:film, name: 'Alien') }

      describe 'on change of name' do
        it 'saves old name in alternate names' do
          film.name = 'Aliens'
          expect { film.save }.to change(film, :alternate_names).from([]).to(['Alien'])
        end
      end
    end
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
    describe '.no_information' do
      let!(:film_1) { create(:film) }
      let!(:film_2) { create(:film, overview: '') }
      let!(:film_3) { create(:film, overview: Faker::Lorem.paragraph) }

      it 'only returns films with no overview' do
        expect(Film.no_information).to eq([film_1, film_2])
      end
    end

    describe '.no_tmdb_details' do
      let!(:film_1) { create(:film) }
      let!(:film_2) { create(:film, tmdb_identifier: 45) }
      let!(:film_3) { create(:film, tmdb_possibles: [1, 2, 3]) }

      it 'only returns films with no tmdb information' do
        expect(Film.no_tmdb_details).to eq([film_1])
      end
    end

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

  describe '.find_or_create_by_name(name)' do
    subject(:find_or_create_by_name) do
      described_class.find_or_create_by_name(name)
    end

    let(:name) { 'Alien' }

    context 'no film of that name exists' do
      it 'creates a new film' do
        expect { find_or_create_by_name }.to change(Film, :count).from(0).to(1)
      end
      it 'returns a film' do
        expect(find_or_create_by_name).to be_a(Film)
      end
      it 'returns a persisted film' do
        expect(find_or_create_by_name).to be_persisted
      end
    end

    context 'film of that name exists' do
      let!(:film) { create(:film, name: 'Alien') }

      it 'does not create a new film' do
        expect { find_or_create_by_name }.not_to change(Film, :count)
      end
      it 'returns film' do
        expect(find_or_create_by_name).to eq(film)
      end
    end

    context 'film of that name (as an alternate) exists' do
      let!(:film) { create(:film, alternate_names: ['Alien']) }

      it 'creates a new film' do
        expect { find_or_create_by_name }.not_to change(Film, :count)
      end
      it 'returns film' do
        expect(find_or_create_by_name).to eq(film)
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
      instance_double(ExternalFilm, imdb_number: 1234567,
                                    overview:    'overview',
                                    runtime:     106,
                                    tagline:     'tagline',
                                    year:        '2000')
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
    it 'sets year' do
      expect { hydrate }.to change(film, :year).to('2000')
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
      expect(Films::StoreBackdrop).to receive(:enqueue).with(film_id: film.id)
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
      expect(Films::StorePoster).to receive(:enqueue).with(film_id: film.id)
      set_poster_source
    end
  end

  describe '#update_possibles(array)' do
    let(:film) { build :film }
    let(:args) { [123, 322, 456] }

    before { film.update_possibles(args) }

    it 'sets the tmdb_possibles array (converts to strings)' do
      expect(film.reload.tmdb_possibles).to eq(args.map(&:to_s))
    end
  end

  describe '#to_param' do
    subject { film.to_param }

    let!(:film) { create(:film, url: 'will-be-name-if-saved') }

    it { is_expected.to be_a(String) }
    it { is_expected.to eq("#{film.id}-#{film.url}") }
  end
end
