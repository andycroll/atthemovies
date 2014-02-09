namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema, brand: 'Cineworld').import_cinemas
    end
  end

  namespace :screenings do
    desc 'Import Cineworld Screenings'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema, brand: 'Cineworld').import_screenings
    end
  end
end
