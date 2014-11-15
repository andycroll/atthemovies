namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema).import_cinemas
    end

    desc 'Import Odeon Cinemas'
    task :odeon => :environment do
      CinemaImporter.new(klass: OdeonUk::Cinema).import_cinemas
    end

    desc 'Import Picturehouse Cinemas'
    task :picturehouse => :environment do
      CinemaImporter.new(klass: PicturehouseUk::Cinema).import_cinemas
    end
  end

  namespace :films do
    desc 'Import possible TMDB ids for movies'
    task :get_ids => :environment do
      MovieInformationImporter.new.get_ids
    end
  end

  namespace :screenings do
    desc 'Import Cineworld Screenings'
    task :cineworld => :environment do
      CinemaImporter.new(klass: CineworldUk::Cinema).import_screenings
    end

    desc 'Import Odeon Screenings'
    task :odeon => :environment do
      CinemaImporter.new(klass: OdeonUk::Cinema).import_screenings
    end

    desc 'Import Picturehouse Screenings'
    task :picturehouse => :environment do
      CinemaImporter.new(klass: PicturehouseUk::Cinema).import_screenings
    end
  end
end
