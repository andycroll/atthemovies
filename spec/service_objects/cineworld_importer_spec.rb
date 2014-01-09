require 'spec_helper'

describe CineworldImporter do
  describe '#import_cinemas' do
    let(:cinema_1) { instance_double('CineworldUk::Cinema') }
    let(:cinema_2) { instance_double('CineworldUk::Cinema') }
    let(:cinemas)  { [cinema_1, cinema_2] }

    before do
      expect(CineworldUk::Cinema).to receive(:all).and_return(cinemas)

      expect(cinema_1).to receive(:name).and_return('Cineworld Brighton')
      expect(cinema_1).to receive(:brand).and_return('Cineworld')
      expect(cinema_1).to receive(:id).and_return(3)
      expect(cinema_1).to receive(:address).and_return({})

      expect(cinema_2).to receive(:name).and_return('Cineworld Wolverhapton')
      expect(cinema_2).to receive(:brand).and_return('Cineworld')
      expect(cinema_2).to receive(:id).and_return(69)
      expect(cinema_2).to receive(:address).and_return({})

      expect(CinemaImporterJob).to receive(:new).with('Cineworld Brighton', 'Cineworld', 3, {}).and_call_original
      expect(CinemaImporterJob).to receive(:new).with('Cineworld Wolverhapton', 'Cineworld', 69, {}).and_call_original
    end

    it 'creates a bunch of import jobs for cinemas' do
      CineworldImporter.new.import_cinemas
      expect(Delayed::Job.count).to eq(2)
    end
  end

  describe '#import_screenings(cinema_id)' do
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

      expect(screening_1).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_1).to receive(:when).and_return(1.hour.from_now.utc)
      expect(screening_1).to receive(:variant).and_return('2D')

      expect(screening_2).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_2).to receive(:when).and_return(2.hours.from_now.utc)
      expect(screening_2).to receive(:variant).and_return('3D kids')

      expect(screening_3).to receive(:film_name).and_return('Avengers')
      expect(screening_3).to receive(:when).and_return(3.hours.from_now.utc)
      expect(screening_3).to receive(:variant).and_return('3D silver')

      expect(screening_4).to receive(:film_name).and_return('Iron Man 3')
      expect(screening_4).to receive(:when).and_return(4.hours.from_now.utc)
      expect(screening_4).to receive(:variant).and_return('3D')

      expect(ScreeningImporterJob).to receive(:new).with(cinema.id, 'Iron Man 3', 1.hour.from_now.utc, '2D').and_call_original
      expect(ScreeningImporterJob).to receive(:new).with(cinema.id, 'Iron Man 3', 2.hours.from_now.utc, '3D kids').and_call_original
      expect(ScreeningImporterJob).to receive(:new).with(cinema.id, 'Avengers', 3.hours.from_now.utc, '3D silver').and_call_original
      expect(ScreeningImporterJob).to receive(:new).with(cinema.id, 'Iron Man 3', 4.hours.from_now.utc, '3D').and_call_original
    end

    after do
      Timecop.return
    end

    it 'creates a bunch of import jobs for screenings' do
      CineworldImporter.new.import_screenings(cinema.id)
      expect(Delayed::Job.count).to eq(4)
    end
  end
end
