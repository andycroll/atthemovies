# frozen_string_literal: true
FactoryBot.define do
  factory :cinema do
    name  { "#{Faker::Address.city} Cinema" }
    brand { 'Independent' }

    trait :with_address do
      street_address   { Faker::Address.street_address }
      locality         { Faker::Address.city }
      region           { Faker::Address.state }
      postal_code      { Faker::Address.postcode }
      country          { 'United Kingdom' }
      country_code     { 'UK' }
    end

    trait :cineworld do
      brand            'Cineworld'
      name             { "Cineworld #{locality || Faker::Address.city}" }
      brand_identifier { rand(1..100) }
    end

    trait :odeon do
      brand            'Odeon'
      name             { "Odeon #{locality || Faker::Address.city}" }
      brand_identifier { name.downcase.gsub(/\s/,'-') }
    end
  end
end
