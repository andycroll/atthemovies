# frozen_string_literal: true
RSpec::Matchers.define :be_eq_to_time do |time_b|
  match do |time_a|
    time_a.to_i == time_b.to_i
  end

  failure_message do |time_a|
    "\nExpected Time: '#{time_a}' to equal\n         Time: '#{time_b}'"
  end

  failure_message_when_negated do |time_a|
    "\nExpected Time: '#{time_a}' NOT to equal\n         Time: '#{time_b}'"
  end

  description do
    "be equal Time objects"
  end
end
