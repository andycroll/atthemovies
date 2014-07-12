namespace :cleanup do
  desc 'Remove Old Screenings'
  task :past_screenings => :environment do
    DestroyPastScreenings.new.perform
  end
end
