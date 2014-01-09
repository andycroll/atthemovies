namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      CineworldImporter.new.import_cinemas
    end
  end

  namespace :screenings do
    desc 'Import Cineworld Screenings'
    task :cineworld => :environment do
      CineworldImporter.new.import_screenings
    end
  end
end
