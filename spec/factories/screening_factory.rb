FactoryGirl.define do
  factory :screening do
    film
    cinema
    showing_at { 2.days.from_now }
    dimension  { %w(2d 3d).sample }
    variant    { ['', 'D-BOX', 'IMAX'].sample }
  end
end
