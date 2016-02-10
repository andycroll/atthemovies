require 'rails_helper'

describe ExternalFilm do
  describe '.find(name)' do
    subject(:find) { described_class.find(name) }

    context 'single result' do
      let(:name)        { 'Crazy Heart' }
      let(:find_result) { [instance_double(Tmdb::Movie, id: 25196)] }

      before do
        expect(Tmdb::Movie).to receive(:find).and_return(find_result)
      end

      it 'returns an array' do
        expect(find).to be_an(Array)
      end

      it 'returns ExternalFilm objects' do
        find.each do |item|
          expect(item).to be_an(described_class)
        end
      end
    end

    context 'multiple results' do
      let(:name) { 'The Dark Knight' }
      let(:find_result) do
        [
          instance_double(Tmdb::Movie, id: 155),
          instance_double(Tmdb::Movie, id: 72_003)
        ]
      end

      before do
        expect(Tmdb::Movie).to receive(:find).and_return(find_result)
      end

      it 'returns an array' do
        expect(find).to be_an(Array)
      end

      it 'returns ExternalFilm objects' do
        find.each do |item|
          expect(item).to be_an(described_class)
        end
      end
    end

    context 'empty results' do
      let(:name)        { 'The Dark Knight' }
      let(:find_result) { [] }

      before do
        expect(Tmdb::Movie).to receive(:find).and_return(find_result)
      end

      it 'returns an empty array' do
        expect(find).to be_an(Array)
        expect(find.length).to be(0)
      end
    end

    context 'empty name' do
      let(:name) { '' }

      it 'returns an empty array' do
        expect(find).to be_an(Array)
        expect(find.length).to be(0)
      end
    end

    context 'empty name' do
      let(:name) { nil }

      it 'returns an empty array' do
        expect(find).to be_an(Array)
        expect(find.length).to be(0)
      end
    end
  end

  describe '#backdrop' do
    subject(:backdrop) { described_class.new(tmdb_id).backdrop }

    let(:tmdb_id) { 25_196 }
    let(:detail_result) do
      { 'id' => tmdb_id, 'backdrop_path' => '/tUyhwp36YykNKpqpEfauCavuDbK.jpg' }
    end
    let(:tmdb_backdrop) { instance_double(ExternalFilm::Backdrop) }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
      expect(ExternalFilm::Backdrop).to receive(:new).with(detail_result['backdrop_path']).and_return(tmdb_backdrop)
    end

    it 'creates a backdrop object using the TMDB data' do
      expect(backdrop).to eq(tmdb_backdrop)
    end
  end

  describe '#imdb_number' do
    subject(:imdb_number) { described_class.new(tmdb_id).imdb_number }

    let(:tmdb_id) { 25_196 }
    let(:detail_result) { { 'id' => tmdb_id, 'imdb_id' => 'tt1263670' } }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
    end

    it { is_expected.to be_a(String) }
    it { is_expected.to eq('tt1263670') }
  end

  describe '#overview' do
    subject(:overview) { described_class.new(tmdb_id).overview }

    let(:tmdb_id) { 25_196 }
    let(:detail_result) { { 'id' => tmdb_id, 'overview' => 'overview' } }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
    end

    it { is_expected.to be_a(String) }
    it { is_expected.to eq('overview') }
  end

  describe '#poster' do
    subject(:poster) { described_class.new(tmdb_id).poster }

    let(:tmdb_id) { 25_196 }
    let(:detail_result) do
      { 'id' => tmdb_id, 'poster_path' => '/tUyhwp36YykNKpqpEfauCavuDbK.jpg' }
    end
    let(:tmdb_poster)   { instance_double(ExternalFilm::Poster) }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
      expect(ExternalFilm::Poster).to receive(:new).with('/tUyhwp36YykNKpqpEfauCavuDbK.jpg').and_return(tmdb_poster)
    end

    it 'creates a poster object using the TMDB data ' do
      expect(poster).to eq(tmdb_poster)
    end
  end

  describe '#runtime' do
    subject(:runtime) { described_class.new(tmdb_id).runtime }

    let(:tmdb_id)       { 25196 }
    let(:detail_result) { { 'id' => tmdb_id, 'runtime' => 106 } }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
    end

    it { is_expected.to be_a(Integer) }
    it { is_expected.to eq(106) }
  end

  describe '#tagline' do
    subject(:tagline) { described_class.new(tmdb_id).tagline }

    let(:tmdb_id)       { 25196 }
    let(:detail_result) { { 'id' => tmdb_id, 'tagline' => 'tagline' } }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
    end

    it { is_expected.to be_a(String) }
    it { is_expected.to eq('tagline') }
  end
end
