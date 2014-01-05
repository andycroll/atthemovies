FactoryGirl.define do
  factory :screening do
    film
    cinema
    showing_at { 2.days.from_now }
    variant { ['2D', '3D', 'IMAX'].sample }
  end
end
