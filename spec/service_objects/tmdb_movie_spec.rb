require 'spec_helper'

describe TmdbMovie do
  describe '.find(name)' do
    subject(:find) { TmdbMovie.find(name) }

    context 'single result' do
      let(:name)        { 'Crazy Heart' }
      let(:find_result) { [instance_double(Tmdb::Movie, id: 25196)] }

      before do
        expect(Tmdb::Movie).to receive(:find).and_return(find_result)
      end

      it 'returns an array' do
        expect(find).to be_an(Array)
      end

      it 'returns TmdbMovie objects' do
        find.each do |item|
          expect(item).to be_an(TmdbMovie)
        end
      end
    end

    context 'multiple results' do
      let(:name)        { 'The Dark Knight' }
      let(:find_result) { [instance_double(Tmdb::Movie, id: 155), instance_double(Tmdb::Movie, id: 72003)] }

      before do
        expect(Tmdb::Movie).to receive(:find).and_return(find_result)
      end

      it 'returns an array' do
        expect(find).to be_an(Array)
      end

      it 'returns TmdbMovie objects' do
        find.each do |item|
          expect(item).to be_an(TmdbMovie)
        end
      end
    end
  end

  describe '#backdrop' do
    subject(:backdrop) { TmdbMovie.new(tmdb_id).backdrop }

    let(:tmdb_id)       { 25196 }
    let(:detail_result) { instance_double(Tmdb::Movie, id: tmdb_id, backdrop_path: '/tUyhwp36YykNKpqpEfauCavuDbK.jpg') }
    let(:tmdb_backdrop) { instance_double(TmdbBackdrop) }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
      expect(TmdbBackdrop).to receive(:new).with(file_path: detail_result.backdrop_path).and_return(tmdb_backdrop)
    end

    it 'creates a backdrop object using the TMDB data' do
      expect(backdrop).to eq(tmdb_backdrop)
    end
  end

  describe '#imdb_number' do
    subject(:imdb_number) { TmdbMovie.new(tmdb_id).imdb_number }

    let(:tmdb_id)       { 25196 }
    let(:detail_result) { instance_double(Tmdb::Movie, id: tmdb_id, imdb_id: 'tt1263670') }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
    end

    it { should be_a(String) }
    it { should eq('tt1263670') }
  end

  describe '#poster' do
    subject(:poster) { TmdbMovie.new(tmdb_id).poster }

    let(:tmdb_id)       { 25196 }
    let(:detail_result) { instance_double(Tmdb::Movie, id: tmdb_id, poster_path: "/tUyhwp36YykNKpqpEfauCavuDbK.jpg") }
    let(:tmdb_poster)   { instance_double(TmdbPoster) }

    before do
      expect(Tmdb::Movie).to receive(:detail).and_return(detail_result)
      expect(TmdbPoster).to receive(:new).with(file_path: "/tUyhwp36YykNKpqpEfauCavuDbK.jpg").and_return(tmdb_poster)
    end

    it 'creates a poster object using the TMDB data ' do
      expect(poster).to eq(tmdb_poster)
    end
  end
end
