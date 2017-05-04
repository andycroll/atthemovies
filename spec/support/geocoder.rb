# frozen_string_literal: true
Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => Faker::Address.latitude,
      'longitude'    => Faker::Address.longitude,
      'address'      => '1 Brighton Street, Brighton',
      'state'        => 'East Sussex',
      'state_code'   => '',
      'country'      => 'United Kingdom',
      'country_code' => 'GB'
    }
  ]
)
