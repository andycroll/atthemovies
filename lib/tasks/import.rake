namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema, brand: 'Cineworld').import_cinemas
    end

    desc 'Import Odeon Cinemas'
    task :odeon => :environment do
      CinemaImporter.new(klass: OdeonUk::Cinema, brand: 'Odeon').import_cinemas
    end
  end

  namespace :screenings do
    desc 'Import Cineworld Screenings'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema, brand: 'Cineworld').import_screenings
    end

    desc 'Import Odeon Screenings'
    task :odeon => :environment do
      CinemaImporter.new(klass: OdeonUk::Cinema, brand: 'Odeon').import_screenings
    end
  end
end
