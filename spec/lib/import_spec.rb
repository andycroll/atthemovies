require 'spec_helper'
require 'rake'

describe 'rake app' do
  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load Rails.root.join('lib', 'tasks', 'import.rake')
    allow(double($stdout)).to receive(:puts) # shush logging
  end

  describe 'import' do
    describe 'cinemas' do
      describe 'cineworld' do
        let(:importer) { instance_double('CineworldImporter') }

        it 'imports using the service object' do
          expect(CineworldImporter).to receive(:new).and_return(importer)
          expect(importer).to receive(:import_cinemas)
          rake['import:cinemas:cineworld'].invoke
        end
      end
    end

    describe 'screenings' do
      describe 'cineworld' do
        let(:importer) { instance_double('CineworldImporter') }

        it 'imports using the service object' do
          expect(CineworldImporter).to receive(:new).and_return(importer)
          expect(importer).to receive(:import_screenings)
          rake['import:screenings:cineworld'].invoke
        end
      end
    end
  end
end
