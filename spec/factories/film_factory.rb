FactoryGirl.define do
  factory :film do
    name  { Faker::Lorem.sentence }

    trait :external_information do
      tmdb_identifier { Faker::Number.number(4) }
      tagline         { Faker::Lorem.sentence }
      overview        { Faker::Lorem.paragraph }
      runtime         { rand(120) + 60 }
      year            { Faker::Date.backward(10_000).year }
    end
  end
end
