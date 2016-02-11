namespace :cleanup do
  desc 'Remove Old Performances'
  task :past_performances => :environment do
    Maintenance::DestroyPastPerformances.new.perform
  end
end
