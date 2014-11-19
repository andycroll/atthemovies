require 'rails_helper'

describe Import::Cinemas do
  describe '#perform' do
    let(:importer) { described_class.new(klass: CineworldUk::Cinema) }

    let(:cinema_1) { instance_double('CineworldUk::Cinema') }
    let(:cinema_2) { instance_double('CineworldUk::Cinema') }
    let(:cinemas)  { [cinema_1, cinema_2] }

    before do
      expect(CineworldUk::Cinema).to receive(:all).and_return(cinemas)

      expect(cinema_1).to receive(:full_name).and_return('Cineworld Brighton')
      expect(cinema_1).to receive(:brand).and_return('Cineworld')
      expect(cinema_1).to receive(:id).and_return(3)
      expect(cinema_1).to receive(:address).and_return({})

      expect(cinema_2).to receive(:full_name).and_return('Cineworld Wolverhapton')
      expect(cinema_2).to receive(:brand).and_return('Cineworld')
      expect(cinema_2).to receive(:id).and_return(69)
      expect(cinema_2).to receive(:address).and_return({})

      expect(Cinemas::Import).to receive(:enqueue).with(name: 'Cineworld Brighton', brand: 'Cineworld', brand_identifier: 3, address: {}).and_call_original
      expect(Cinemas::Import).to receive(:enqueue).with(name: 'Cineworld Wolverhapton', brand: 'Cineworld', brand_identifier: 69, address: {}).and_call_original
    end

    it 'creates a bunch of import jobs for cinemas' do
      importer.perform
      expect(Delayed::Job.count).to eq(2)
    end
  end
end
