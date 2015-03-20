require 'rails_helper'
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
    let(:importer) { instance_double('Import::Cinemas') }

    describe 'cinemas' do
      describe 'cineworld' do
        it 'imports using the service object' do
          expect(Import::Cinemas).to receive(:new)
            .with(klass: CineworldUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:cinemas:cineworld'].invoke
        end
      end

      describe 'odeon' do
        it 'imports using the service object' do
          expect(Import::Cinemas).to receive(:new)
            .with(klass: OdeonUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:cinemas:odeon'].invoke
        end
      end

      describe 'picturehouse' do
        it 'imports using the service object' do
          expect(Import::Cinemas).to receive(:new)
            .with(klass: PicturehouseUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:cinemas:picturehouse'].invoke
        end
      end
    end

    describe 'films' do
      describe 'external_ids' do
        it 'imports using the service object' do
          expect(Import::ExternalFilmIds).to receive(:new).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:films:external_ids'].invoke
        end
      end
    end

    describe 'screenings' do
      describe 'cineworld' do
        it 'imports using the service object' do
          expect(Import::Screenings).to receive(:new)
            .with(klass: CineworldUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:screenings:cineworld'].invoke
        end
      end

      describe 'odeon' do
        it 'imports using the service object' do
          expect(Import::Screenings).to receive(:new)
            .with(klass: OdeonUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:screenings:odeon'].invoke
        end
      end

      describe 'picturehouse' do
        it 'imports using the service object' do
          expect(Import::Screenings).to receive(:new)
            .with(klass: PicturehouseUk::Cinema).and_return(importer)
          expect(importer).to receive(:perform)
          rake['import:screenings:picturehouse'].invoke
        end
      end
    end
  end
end
