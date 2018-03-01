# frozen_string_literal: true
FactoryBot.define do
  factory :performance do
    film
    cinema
    starting_at { 2.days.from_now }
    dimension { %w(2d 3d).sample }
    variant { ['', 'D-BOX', 'IMAX'].sample }
  end
end
