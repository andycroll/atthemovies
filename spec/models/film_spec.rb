require 'spec_helper'

describe Film do
  describe 'validations' do
    it { should validate_presence_of :name }
  end

  describe '#set_possibles(array)' do
    let(:film) { build :film }
    let(:args) { [123, 322, 456] }

    before { film.set_possibles(args) }

    it 'sets the tmdb_possibles array (converts to strings)' do
      expect(film.reload.tmdb_possibles).to eq(args.map(&:to_s))
    end
  end
end
