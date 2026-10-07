namespace :imports do
  desc "Show import data and retained Solid Queue failures"
  task status: :environment do
    puts "Cinemas: #{Cinema.count}, films: #{Film.count}, future performances: #{Performance.upcoming.count}"
    puts "Film states: #{Film.group(:enrichment_state).count}"
    puts "Failed jobs: #{SolidQueue::FailedExecution.count}"
    SolidQueue::FailedExecution.includes(:job).order(created_at: :desc).limit(20).each do |failure|
      puts "#{failure.created_at.iso8601} #{failure.job.class_name} job=#{failure.job_id}"
    end
  end
end
