require 'bundler/setup'

require 'sniff'
Sniff.init File.expand_path('../../..', __FILE__),
  :cucumber => true,
  :logger => false # change this to $stderr to see database activity

require 'geocoder'
class GeocoderWrapper
  def geocode(input)
    if res = ::Geocoder.search(input).first
      {
        latitude:  res.coordinates[0],
        longitude: res.coordinates[1],
      }
    end
  end

  def distance_between(origin, destination)
    Geocoder::Calculations.distance_between origin.values_at(:latitude, :longitude).join(','), destination.values_at(:latitude, :longitude).join(','), :units => :km
  end
end
BrighterPlanet::Shipment.geocoder = GeocoderWrapper.new
