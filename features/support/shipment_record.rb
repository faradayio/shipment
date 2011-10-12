require 'active_record'
require 'falls_back_on'
require 'shipment'
require 'sniff'

class ShipmentRecord < ActiveRecord::Base
  include BrighterPlanet::Emitter
  include BrighterPlanet::Shipment
end
