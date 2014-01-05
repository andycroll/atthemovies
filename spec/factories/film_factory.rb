FactoryGirl.define do
  factory :film do
    name  { Faker::Address.words }
  end
end
