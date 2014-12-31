require 'rails_helper'

describe Import::Screenings do
  describe '#perform' do
    let(:importer) { described_class.new(klass: CineworldUk::Cinema) }

    let!(:cineworld_1) { create :cinema, :cineworld }
    let!(:cineworld_2) { create :cinema, :cineworld }
    let!(:odeon_1)     { create :cinema, :odeon }

    it 'imports screenings for each cineworld cinema' do
      expect(importer).to receive(:perform_for).with(cineworld_1)
      expect(importer).to receive(:perform_for).with(cineworld_2)
      expect(importer).not_to receive(:perform_for).with(odeon_1)

      importer.perform
    end
  end

  describe '#perform_for(cinema)' do
    let(:importer) { described_class.new(klass: OdeonUk::Cinema) }

    let(:odeon_cinema)   { instance_double('OdeonUk::Cinema') }
    let(:odeon_brand_id) { 3 }

    let!(:cinema) { create(:cinema, :odeon, brand_identifier: odeon_brand_id) }

    let(:screening_1) { instance_double('OdeonUk::Screening') }
    let(:screening_2) { instance_double('OdeonUk::Screening') }
    let(:screening_3) { instance_double('OdeonUk::Screening') }
    let(:screening_4) { instance_double('OdeonUk::Screening') }

    before do
      Timecop.freeze

      expect(OdeonUk::Cinema).to receive(:find).with(odeon_brand_id.to_s).and_return(odeon_cinema)
      expect(odeon_cinema).to receive(:screenings).and_return([screening_1, screening_2, screening_3, screening_4])

      expect(screening_1).to receive(:dimension).and_return('2d')
      expect(screening_1).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_1).to receive(:showing_at).and_return(1.hour.from_now.utc)
      expect(screening_1).to receive(:variant).and_return([]).twice

      expect(screening_2).to receive(:dimension).and_return('2d')
      expect(screening_2).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_2).to receive(:showing_at).and_return(2.hours.from_now.utc)
      expect(screening_2).to receive(:variant).and_return(%w(kids baby)).twice

      expect(screening_3).to receive(:dimension).and_return('2d')
      expect(screening_3).to receive(:film_name).and_return('Avengers')
      expect(screening_3).to receive(:showing_at).and_return(3.hours.from_now.utc)
      expect(screening_3).to receive(:variant).and_return('silver').twice

      expect(screening_4).to receive(:dimension).and_return('3d')
      expect(screening_4).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_4).to receive(:showing_at).and_return(4.hours.from_now.utc)
      expect(screening_4).to receive(:variant).and_return('').twice
    end

    after do
      Timecop.return
    end

    it 'creates a bunch of import jobs for screenings' do
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        showing_at: 1.hour.from_now.utc.to_s,
        variant: ''
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        showing_at: 2.hours.from_now.utc.to_s,
        variant: 'kids baby'
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Avengers',
        showing_at: 3.hours.from_now.utc.to_s,
        variant: 'silver'
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '3d',
        film_name: 'Iron Man 3',
        showing_at: 4.hours.from_now.utc.to_s,
        variant: ''
      ).and_call_original

      importer.perform_for(cinema)
    end
  end

  describe '#perform(cinema)', 'CineworldUk' do
    let(:importer) { described_class.new(klass: CineworldUk::Cinema) }

    let(:cineworld_cinema)   { instance_double('CineworldUk::Cinema') }
    let(:cineworld_brand_id) { 3 }

    let!(:cinema) { create(:cinema, :cineworld, brand_identifier: cineworld_brand_id) }

    let(:screening_1) { instance_double('CineworldUk::Screening') }
    let(:screening_2) { instance_double('CineworldUk::Screening') }
    let(:screening_3) { instance_double('CineworldUk::Screening') }
    let(:screening_4) { instance_double('CineworldUk::Screening') }

    before do
      Timecop.freeze

      expect(CineworldUk::Cinema).to receive(:find).with(cineworld_brand_id.to_s).and_return(cineworld_cinema)
      expect(cineworld_cinema).to receive(:screenings).and_return([screening_1, screening_2, screening_3, screening_4])

      expect(screening_1).to receive(:dimension).and_return('2d')
      expect(screening_1).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_1).to receive(:showing_at).and_return(1.hour.from_now.utc)
      expect(screening_1).to receive(:variant).and_return([]).twice

      expect(screening_2).to receive(:dimension).and_return('2d')
      expect(screening_2).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_2).to receive(:showing_at).and_return(2.hours.from_now.utc)
      expect(screening_2).to receive(:variant).and_return(%w(kids baby)).twice

      expect(screening_3).to receive(:dimension).and_return('2d')
      expect(screening_3).to receive(:film_name).and_return('Avengers')
      expect(screening_3).to receive(:showing_at).and_return(3.hours.from_now.utc)
      expect(screening_3).to receive(:variant).and_return('silver').twice

      expect(screening_4).to receive(:dimension).and_return('3d')
      expect(screening_4).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_4).to receive(:showing_at).and_return(4.hours.from_now.utc)
      expect(screening_4).to receive(:variant).and_return('').twice
    end

    after do
      Timecop.return
    end

    it 'creates a bunch of import jobs for screenings' do
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        showing_at: 1.hour.from_now.utc.to_s,
        variant: ''
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Iron Man 3',
        showing_at: 2.hours.from_now.utc.to_s,
        variant: 'kids baby'
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '2d',
        film_name: 'Avengers',
        showing_at: 3.hours.from_now.utc.to_s,
        variant: 'silver'
      ).and_call_original
      expect(Screenings::Import).to receive(:perform_later).with(
        cinema_id: cinema.id,
        dimension: '3d',
        film_name: 'Iron Man 3',
        showing_at: 4.hours.from_now.utc.to_s,
        variant: ''
      ).and_call_original

      importer.perform_for(cinema)
    end
  end
end
