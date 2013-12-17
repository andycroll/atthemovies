FactoryGirl.define do
  factory :cinema do
    name             { %w(Cineworld Odeon Vue).sample + " #{locality}" }
    street_address   { Faker::Address.street_address }
    locality         { Faker::Address.city }
    region           { Faker::Address.state }
    postal_code      { Faker::Address.postcode }
    country          { 'United Kingdom' }
    country_code     { 'UK' }
  end
end
