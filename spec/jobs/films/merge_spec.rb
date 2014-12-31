require 'rails_helper'

describe Films::Merge do
  let(:job) { described_class.new.perform(film, other_film) }

  describe '#perform' do
    context 'standard' do
      let!(:film)        { create(:film, id: 1, name: 'Batman') }
      let!(:other_film)  { create(:film, id: 2, name: 'Batman One') }
      let!(:screening_1) { create(:screening, film: other_film) }
      let!(:screening_2) { create(:screening, film: other_film) }

      it 'adds other film name to film' do
        expect(film.reload.alternate_names).to eq([])
        job
        expect(film.reload.alternate_names).to eq(['Batman One'])
      end

      it 'moves other film screenings to film' do
        job
        expect(screening_1.reload.film).to eq(film)
        expect(screening_2.reload.film).to eq(film)
      end

      it 'deletes other film' do
        expect { job }.to change(Film, :count).from(2).to(1)
      end
    end

    context 'same film name' do
      let!(:film)        { create(:film, id: 1, name: 'Batman') }
      let!(:other_film)  { create(:film, id: 2, name: 'Batman') }
      let!(:screening_1) { create(:screening, film: other_film) }
      let!(:screening_2) { create(:screening, film: other_film) }

      it 'does not repetition of name to film' do
        expect(film.reload.alternate_names).to eq([])
        job
        expect(film.reload.alternate_names).to eq([])
      end

      it 'moves other film screenings to film' do
        job
        expect(screening_1.reload.film).to eq(film)
        expect(screening_2.reload.film).to eq(film)
      end

      it 'deletes other film' do
        expect { job }.to change(Film, :count).from(2).to(1)
      end
    end
  end
end
