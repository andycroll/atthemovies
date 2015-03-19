FactoryGirl.define do
  factory :film do
    name  { Faker::Lorem.sentence }

    trait :external_id do
      tmdb_identifier { Faker::Number.number(4) }
    end

    trait :external_information do
      tagline         { Faker::Lorem.sentence }
      overview        { Faker::Lorem.paragraph }
      runtime         { rand(120) + 60 }
      year            { Faker::Date.backward(10_000).year }
    end

    trait :hydrated do
      external_id
      external_information
      information_added true
    end
  end
end
