FactoryGirl.define do
  factory :cinema do
    name     { brand + " #{locality || Faker::Address.city}" }
    brand    { %w(Cineworld Odeon Vue).sample }
    brand_id { rand(1..100) }

    trait :with_address do
      street_address   { Faker::Address.street_address }
      locality         { Faker::Address.city }
      region           { Faker::Address.state }
      postal_code      { Faker::Address.postcode }
      country          { 'United Kingdom' }
      country_code     { 'UK' }
    end

    trait :cineworld do
      brand 'Cineworld'
    end
  end
end
