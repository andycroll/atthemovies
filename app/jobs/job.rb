class Job

  def initialize(args)
  end

  def self.enqueue(args)
    Delayed::Job.enqueue self.new(args)
  end
end
