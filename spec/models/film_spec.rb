require 'spec_helper'

describe Film do
  describe 'validations' do
    it { should validate_presence_of :name }
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

    it { should be_a(String) }
    it { should eq(film.url) }
  end
end
