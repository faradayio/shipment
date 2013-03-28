require 'bundler/setup'

require 'sniff'
Sniff.init File.expand_path('../../..', __FILE__),
  :cucumber => true,
  :logger => false # change this to $stderr to see database activity

require 'geocoder'
class GeocoderWrapper
  def geocode(input, country = 'US')
    if input.is_a?(String)
      input = input + " #{country}"
    else
      input[:country] ||= country
    end
    if res = ::Geocoder.search(input).first
      {
        latitude:  res.coordinates[0],
        longitude: res.coordinates[1],
      }
    end
  end

  def distance_between(origin, destination)
    Geocoder::Calculations.distance_between origin.values_at(:latitude, :longitude), destination.values_at(:latitude, :longitude), :units => :km
  end
end
BrighterPlanet::Shipment.geocoder = GeocoderWrapper.new
