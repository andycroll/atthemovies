class ApplicationJob < ActiveJob::Base
  retry_on HttpClient::Error, Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, SocketError, Errno::ECONNRESET, wait: :polynomially_longer, attempts: 5
  retry_on ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, wait: 2.seconds, attempts: 5
  discard_on ActiveJob::DeserializationError
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
