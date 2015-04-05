Geocoder.configure(:lookup => :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => Random.new.rand(-1.0..1.0),
      'longitude'    => Random.new.rand(49.0..52.0),
      'address'      => '1 Brighton Street, Brighton',
      'state'        => 'East Sussex',
      'state_code'   => '',
      'country'      => 'United Kingdom',
      'country_code' => 'GB'
    }
  ]
)
