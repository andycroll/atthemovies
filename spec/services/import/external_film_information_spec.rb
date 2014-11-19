require 'rails_helper'

describe Import::ExternalFilmInformation do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:film_1) { instance_double('Film', id: rand(999)) }
    let(:film_2) { instance_double('Film', id: rand(999)) }

    it 'creates jobs to find TMDB ids' do
      expect(Film).to receive(:no_information).and_return([film_1, film_2])

      expect(Films::Hydrate).to receive(:enqueue)
        .with(film_id: film_1.id)
      expect(Films::Hydrate).to receive(:enqueue)
        .with(film_id: film_2.id)

      perform
    end
  end
end
