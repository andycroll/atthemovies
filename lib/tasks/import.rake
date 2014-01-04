namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      CineworldImporter.new.import_cinemas
    end
  end
end
