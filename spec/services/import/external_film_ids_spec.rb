# frozen_string_literal: true
require 'rails_helper'

describe Import::ExternalFilmIds do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:film_1) { instance_double('Film', id: rand(999)) }
    let(:film_2) { instance_double('Film', id: rand(999)) }

    it 'creates jobs to find TMDB ids' do
      expect(Film).to receive(:no_tmdb_details).and_return([film_1, film_2])

      expect(Films::FetchExternalIds).to receive(:perform_later).with(film_1)
      expect(Films::FetchExternalIds).to receive(:perform_later).with(film_2)

      perform
    end
  end
end
