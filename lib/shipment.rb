require 'emitter'

require 'shipment/impact_model'
require 'shipment/characterization'
require 'shipment/data'
require 'shipment/relationships'
require 'shipment/summarization'

require 'mapquest_directions'
require 'geocoder'

module BrighterPlanet
  module Shipment
    extend BrighterPlanet::Emitter
  end
end
