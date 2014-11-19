namespace :cleanup do
  desc 'Remove Old Screenings'
  task :past_screenings => :environment do
    Maintenance::DestroyPastScreenings.new.perform
  end
end
