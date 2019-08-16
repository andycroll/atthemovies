# frozen_string_literal: true
FactoryBot.define do
  factory :film do
    name  { Faker::Lorem.sentence }

    trait :external_id do
      tmdb_identifier { Faker::Number.number(digits: 4) }
    end

    trait :information do
      tagline         { Faker::Lorem.sentence }
      overview        { Faker::Lorem.paragraph }
      runtime         { rand(120) + 60 }
      year            { Faker::Date.backward(days: 10_000).year }
    end

    trait :information_added do
      external_id
      information
      information_added { true }
    end
  end
end
