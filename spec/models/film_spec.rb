# frozen_string_literal: true
require 'rails_helper'

describe Film do
  describe 'associations' do
    it { is_expected.to have_many :performances }
  end

  describe 'callbacks' do
    describe 'before save' do
      context 'new film' do
        let(:film) { build(:film, name: 'Alien') }

        it 'stores name as hash' do
          expect { film.save }.to change(film, :name_hashes).to(['aeiln'])
        end
      end

      context 'existing film' do
        let(:film) { create(:film, name: 'Alien') }

        it 'stores name change as hash' do
          expect do
            film.update_attributes(name: 'Alien: Directors Cut')
          end.to change(film, :name_hashes).to(%w(aeiln accdeeiilnorrsttu))
        end
      end

      context 'existing film changes name back' do
        let(:film) { create(:film, name: 'Alien') }

        it 'stores name change as hash only once' do
          expect do
            film.update_attributes(name: 'Alien: Directors Cut')
            film.update_attributes(name: 'Alien')
          end.to change(film, :name_hashes).to(%w(aeiln accdeeiilnorrsttu))
        end
      end
    end

    describe 'before update' do
      describe 'on change of name' do
        let!(:film) { create(:film, name: 'Alien') }

        it 'saves old name in alternate names' do
          film.name = 'Aliens'
          expect { film.save }.to change(film, :alternate_names).from([]).to(['Alien'])
        end
      end

      describe 'on change of tmdb_identifier' do
        let!(:film) { create(:film, :information_added) }

        it 'sets information_added to false' do
          film.tmdb_identifier = 12345
          expect { film.save }.to change(film, :information_added).from(true).to(false)
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
      let!(:film_2) { create(:film, information_added: false) }
      let!(:film_3) { create(:film, information_added: true) }

      it 'only returns films with no overview' do
        expect(Film.no_information.to_a).to include(film_1, film_2)
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
        expect(Film.similar_to('Alien Resurrection')).to include(film_1)
        expect(Film.similar_to('Alien Resurrection')).not_to include(film_2)
        expect(Film.similar_to('Alien Resurrection')).to include(film_3)
      end
    end

    describe '.whats_on' do
      let!(:film_1) { create(:film) }
      let!(:film_2) { create(:film) }
      let!(:film_3) { create(:film) }
      let!(:performance_1_1) { create(:performance, film: film_1) }
      let!(:performance_2_1) { create(:performance, film: film_2) }
      let!(:performance_2_2) { create(:performance, film: film_2) }

      it 'only returns films with performances' do
        expect(Film.whats_on).not_to include(film_3)
      end

      it 'returns films in order of greatest number of performances' do
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

    context 'film of that name (different case) exists' do
      let!(:film) { create(:film, name: 'alien') }

      it 'creates a new film' do
        expect { find_or_create_by_name }.not_to change(Film, :count)
      end
      it 'returns film' do
        expect(find_or_create_by_name).to eq(film)
      end
    end

    context 'film of that name (as an hash) exists' do
      let!(:film) { create(:film, name: 'alien', name_hashes: ['aeiln']) }

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

    it 'joins name only once primary film' do
      add_alternate_name
      add_alternate_name
      expect(film.reload.alternate_names).to include('Extra Name')
      expect(film.reload.alternate_names.count).to eq(1)
    end
  end

  describe '#needs_external_information?' do
    subject(:needs_external_information?) { film.needs_external_information? }

    context 'has external id' do
      context 'has had information added' do
        let(:film) { build :film, :information }
        it { is_expected.to be_falsey }
      end

      context 'no information added' do
        let(:film) { build :film, :external_id }
        it { is_expected.to be_truthy }
      end

      context 'has information manually added' do
        let(:film) { build :film, :external_id, :information }
        it { is_expected.to be_truthy }
      end
    end

    context 'has no external id' do
      let(:film) { build :film }
      it { is_expected.to be_falsey }
    end
  end

  describe '#update_external_information_from(tmdb_movie)' do
    subject { film.update_external_information_from(tmdb_movie) }

    let(:film)       { build :film }
    let(:tmdb_movie) do
      instance_double(ExternalFilm, title:       'Batman',
                                    imdb_number: 1234567,
                                    overview:    'overview',
                                    runtime:     106,
                                    tagline:     'tagline',
                                    poster:      double(uri: 'poster.jpg'),
                                    backdrop:    double(uri: 'backdrop.jpg'),
                                    year:        '2000')
    end

    it 'sets imdb_identifier' do
      expect { subject }.to change(film, :name).to('Batman')
    end
    it 'sets imdb_identifier' do
      expect { subject }.to change(film, :imdb_identifier).to('1234567')
    end
    it 'sets overview' do
      expect { subject }.to change(film, :overview).to('overview')
    end
    it 'sets runtime' do
      expect { subject }.to change(film, :runtime).to(106)
    end
    it 'sets tagline' do
      expect { subject }.to change(film, :tagline).to('tagline')
    end
    it 'sets year' do
      expect { subject }.to change(film, :year).to('2000')
    end
    it 'sets information_added' do
      expect { subject }.to change(film, :information_added).to(true)
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
end
