require 'rails_helper'

describe Import::Performances do
  describe '#perform' do
    let(:importer) { described_class.new(klass: CineworldUk::Performance) }

    let!(:cineworld_1) { create :cinema, :cineworld }
    let!(:cineworld_2) { create :cinema, :cineworld }
    let!(:odeon_1)     { create :cinema, :odeon }

    it 'imports performances for each cineworld cinema' do
      expect(importer).to receive(:perform_for).with(cineworld_1)
      expect(importer).to receive(:perform_for).with(cineworld_2)
      expect(importer).not_to receive(:perform_for).with(odeon_1)

      importer.perform
    end
  end

  describe '#perform_for(cinema)' do
    let(:importer) { described_class.new(klass: OdeonUk::Performance) }

    let(:odeon_cinema)   { instance_double('OdeonUk::Cinema') }
    let(:odeon_brand_id) { 3 }

    let!(:cinema) { create(:cinema, :odeon, brand_identifier: odeon_brand_id) }

    let(:performance_1) { instance_double('OdeonUk::Performance') }
    let(:performance_2) { instance_double('OdeonUk::Performance') }
    let(:performance_3) { instance_double('OdeonUk::Performance') }
    let(:performance_4) { instance_double('OdeonUk::Performance') }

    before do
      Timecop.freeze

      expect(OdeonUk::Performance).to receive(:at).with(odeon_brand_id.to_s).and_return([performance_1, performance_2, performance_3, performance_4])

      expect(performance_1).to receive(:dimension).and_return('2d')
      expect(performance_1).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_1).to receive(:starting_at).and_return(1.hour.from_now.utc)
      expect(performance_1).to receive(:variant).and_return([])

      expect(performance_2).to receive(:dimension).and_return('2d')
      expect(performance_2).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_2).to receive(:starting_at).and_return(2.hours.from_now.utc)
      expect(performance_2).to receive(:variant).and_return(%w(kids baby))

      expect(performance_3).to receive(:dimension).and_return('2d')
      expect(performance_3).to receive(:film_name).and_return('Avengers')
      expect(performance_3).to receive(:starting_at).and_return(3.hours.from_now.utc)
      expect(performance_3).to receive(:variant).and_return(['silver'])

      expect(performance_4).to receive(:dimension).and_return('3d')
      expect(performance_4).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_4).to receive(:starting_at).and_return(4.hours.from_now.utc)
      expect(performance_4).to receive(:variant).and_return([])
    end

    after do
      Timecop.return
    end

    it 'creates a bunch of import jobs for performances' do
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        starting_at: 1.hour.from_now.utc.to_s,
        variant: ''
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        starting_at: 2.hours.from_now.utc.to_s,
        variant: 'kids baby'
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Avengers',
        starting_at: 3.hours.from_now.utc.to_s,
        variant: 'silver'
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '3d',
        film_name: 'Iron Man 3',
        starting_at: 4.hours.from_now.utc.to_s,
        variant: ''
      ).and_call_original

      importer.perform_for(cinema)
    end
  end

  describe '#perform(cinema)', 'CineworldUk' do
    let(:importer) { described_class.new(klass: CineworldUk::Performance) }

    let(:cineworld_cinema)   { instance_double('CineworldUk::Cinema') }
    let(:cineworld_brand_id) { 3 }

    let!(:cinema) { create(:cinema, :cineworld, brand_identifier: cineworld_brand_id) }

    let(:performance_1) { instance_double('CineworldUk::Performance') }
    let(:performance_2) { instance_double('CineworldUk::Performance') }
    let(:performance_3) { instance_double('CineworldUk::Performance') }
    let(:performance_4) { instance_double('CineworldUk::Performance') }

    before do
      Timecop.freeze

      expect(CineworldUk::Performance).to receive(:at).with(cineworld_brand_id.to_s).and_return([performance_1, performance_2, performance_3, performance_4])

      expect(performance_1).to receive(:dimension).and_return('2d')
      expect(performance_1).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_1).to receive(:starting_at).and_return(1.hour.from_now.utc)
      expect(performance_1).to receive(:variant).and_return([])

      expect(performance_2).to receive(:dimension).and_return('2d')
      expect(performance_2).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_2).to receive(:starting_at).and_return(2.hours.from_now.utc)
      expect(performance_2).to receive(:variant).and_return(%w(kids baby))

      expect(performance_3).to receive(:dimension).and_return('2d')
      expect(performance_3).to receive(:film_name).and_return('Avengers')
      expect(performance_3).to receive(:starting_at).and_return(3.hours.from_now.utc)
      expect(performance_3).to receive(:variant).and_return(['silver'])

      expect(performance_4).to receive(:dimension).and_return('3d')
      expect(performance_4).to receive(:film_name).and_return('Iron Man 3')
      expect(performance_4).to receive(:starting_at).and_return(4.hours.from_now.utc)
      expect(performance_4).to receive(:variant).and_return([])
    end

    after do
      Timecop.return
    end

    it 'creates a bunch of import jobs for performances' do
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        starting_at: 1.hour.from_now.utc.to_s,
        variant: ''
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        starting_at: 2.hours.from_now.utc.to_s,
        variant: 'kids baby'
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Avengers',
        starting_at: 3.hours.from_now.utc.to_s,
        variant: 'silver'
      ).and_call_original
      expect(Performances::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '3d',
        film_name: 'Iron Man 3',
        starting_at: 4.hours.from_now.utc.to_s,
        variant: ''
      ).and_call_original

      importer.perform_for(cinema)
    end
  end
end
