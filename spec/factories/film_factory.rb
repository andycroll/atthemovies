FactoryGirl.define do
  factory :film do
    name  { Faker::Lorem.sentence }
  end
end
