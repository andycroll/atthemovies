# frozen_string_literal: true
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
      expect(cinema_1).to receive(:url).and_return('http://cinema.com/31')

      expect(cinema_2).to receive(:full_name).and_return('Cineworld Wolverhapton')
      expect(cinema_2).to receive(:brand).and_return('Cineworld')
      expect(cinema_2).to receive(:id).and_return(69)
      expect(cinema_2).to receive(:address).and_return({})
      expect(cinema_2).to receive(:url).and_return('http://cinema.com/69')

    end

    it 'creates a bunch of import jobs for cinemas' do
      expect(Cinemas::Import).to receive(:perform_later)
        .with(name:             'Cineworld Brighton',
              brand:            'Cineworld',
              brand_identifier: 3,
              address:          {},
              screenings_url:   'http://cinema.com/31')
        .and_call_original
      expect(Cinemas::Import).to receive(:perform_later)
        .with(name:             'Cineworld Wolverhapton',
              brand:            'Cineworld',
              brand_identifier: 69,
              address:          {},
              screenings_url:   'http://cinema.com/69')
        .and_call_original

      importer.perform
    end
  end
end
