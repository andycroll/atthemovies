require 'rails_helper'

describe Films::Merge do
  let(:merge) do
    described_class.new(film_id: film.id, other_film_id: other_film.id)
  end

  let!(:film)        { create(:film, id: 1, name: 'Batman') }
  let!(:other_film)  { create(:film, id: 2, name: 'Batman One') }
  let!(:screening_1) { create(:screening, film: other_film) }
  let!(:screening_2) { create(:screening, film: other_film) }

  describe '#perform' do
    subject(:perform) { merge.perform }

    it 'adds other film name to film' do
      expect(film.reload.alternate_names).to eq([])
      perform
      expect(film.reload.alternate_names).to eq(['Batman One'])
    end

    it 'moves other film screenings to film' do
      perform
      expect(screening_1.reload.film).to eq(film)
      expect(screening_2.reload.film).to eq(film)
    end

    it 'deletes other film' do
      expect { perform }.to change(Film, :count).from(2).to(1)
    end
  end
end
