require 'spec_helper'

describe CineworldImporter do
  describe '#import' do
    let(:cinema_1) { instance_double('CineworldUk::Cinema') }
    let(:cinema_2) { instance_double('CineworldUk::Cinema') }
    let(:cinemas)  { [cinema_1, cinema_2] }

    before do
      expect(CineworldUk::Cinema).to receive(:all).and_return(cinemas)

      expect(cinema_1).to receive(:name).and_return('Cineworld Brighton')
      expect(cinema_1).to receive(:brand).and_return('Cineworld')
      expect(cinema_1).to receive(:address).and_return({})

      expect(cinema_2).to receive(:name).and_return('Cineworld Worthing')
      expect(cinema_2).to receive(:brand).and_return('Cineworld')
      expect(cinema_2).to receive(:address).and_return({})

      expect(CinemaImporterJob).to receive(:new).with('Cineworld Brighton', 'Cineworld', {}).and_call_original
      expect(CinemaImporterJob).to receive(:new).with('Cineworld Worthing', 'Cineworld', {}).and_call_original
    end

    it 'creates a bunch of import jobs' do
      CineworldImporter.new.import
      expect(Delayed::Job.count).to eq(2)
    end
  end
end
