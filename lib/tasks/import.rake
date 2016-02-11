namespace :import do
  namespace :cinemas do
    desc 'Import Cineworld Cinemas'
    task :cineworld => :environment do
      Import::Cinemas.new(klass: CineworldUk::Cinema).perform
    end

    desc 'Import Odeon Cinemas'
    task :odeon => :environment do
      Import::Cinemas.new(klass: OdeonUk::Cinema).perform
    end

    desc 'Import Picturehouse Cinemas'
    task :picturehouse => :environment do
      Import::Cinemas.new(klass: PicturehouseUk::Cinema).perform
    end
  end

  namespace :films do
    desc 'Import possible TMDB ids for movies'
    task :external_ids => :environment do
      Import::ExternalFilmIds.new.perform
    end

    task :external_information => :environment do
      Import::ExternalFilmInformation.new.perform
    end
  end

  namespace :screenings do
    desc 'Import Cineworld Screenings'
    task :cineworld => :environment do
      Import::Screenings.new(klass: CineworldUk::Performance).perform
    end

    desc 'Import Odeon Screenings'
    task :odeon => :environment do
      Import::Screenings.new(klass: OdeonUk::Performance).perform
    end

    desc 'Import Picturehouse Screenings'
    task :picturehouse => :environment do
      Import::Screenings.new(klass: PicturehouseUk::Performance).perform
    end
  end
end
