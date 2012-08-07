# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

require 'geokit'
require 'earth/shipping/carrier'
require 'earth/shipping/carrier_mode'

## Shipment carbon model
# This model is used by [Brighter Planet](http://brighterplanet.com)'s carbon emission [web service](http://carbon.brighterplanet.com) to estimate the **greenhouse gas emissions of a shipment** (e.g. a FedEx package).
#
##### Timeframe and date
# The model estimates the emissions that occur during a particular `timeframe`. To do this it needs to know the shipment's `date`. For example, if the `timeframe` is January 2010, a shipment that occurred on January 11 2010 will have emissions but a shipment that occurred on Febraury 1 2010 will not.
#
##### Calculations
# The final estimate is the result of the **calculations** detailed below. These calculations are performed in reverse order, starting with the last calculation listed and finishing with the `emission` calculation. Each calculation is named according to the value it returns.
#
##### Methods
# To accomodate varying client input, each calculation may have one or more **methods**. These are listed under each calculation in order from most to least preferred. Each method is named according to the values it requires. If any of these values is not available the method will be ignored. If all the methods for a calculation are ignored, the calculation will not return a value. "Default" methods do not require any values, and so a calculation with a default method will always return a value.
#
##### Standard compliance
# Each method lists any established calculation standards with which it **complies**. When compliance with a standard is requested, all methods that do not comply with that standard are ignored. This means that any values a particular method requires will have been calculated using a compliant method, because those are the only methods available. If any value did not have a compliant method in its calculation then it would be undefined, and the current method would have been ignored.
#
##### Collaboration
# Contributions to this carbon model are actively encouraged and warmly welcomed. This library includes a comprehensive test suite to ensure that your changes do not cause regressions. All changes should include test coverage for new functionality. Please see [sniff](https://github.com/brighterplanet/sniff#readme), our emitter testing framework, for more information.
module BrighterPlanet
  module Shipment
    module ImpactModel
      def self.included(base)
        base.decide :impact, :with => :characteristics do
          committee :carbon do
            # FIXME TODO deal with timeframe
            quorum 'from transport emission and corporate emission', :needs => [:transport_emission, :corporate_emission] do |characteristics|
              characteristics[:transport_emission] + characteristics[:corporate_emission]
            end
          end
          
          committee :corporate_emission do
            quorum 'from package count and corporate emission factor', :needs => [:package_count, :corporate_emission_factor] do |characteristics|
              characteristics[:package_count] * characteristics[:corporate_emission_factor]
            end
          end
          
          committee :transport_emission do
            quorum 'from weight, adjusted distance, and transport emission factor', :needs => [:weight, :adjusted_distance, :transport_emission_factor] do |characteristics|
              # we're assuming that the number of stops, rather than number of packages carried, is limiting factor on local delivery routes
              characteristics[:weight] * characteristics[:adjusted_distance] * characteristics[:transport_emission_factor]
            end
          end
          
          committee :corporate_emission_factor do
            quorum 'from carrier', :needs => :carrier do |characteristics|
              characteristics[:carrier].corporate_emission_factor
            end
            
            quorum 'default' do
              Carrier.fallback.corporate_emission_factor
            end
          end
          
          committee :transport_emission_factor do
            quorum 'from carrier mode, weight, and adjusted distance', :needs => [:carrier_mode, :weight, :adjusted_distance] do |characteristics|
              if characteristics[:carrier_mode].mode_name == "courier"
                characteristics[:carrier_mode].transport_emission_factor / (characteristics[:weight] * characteristics[:adjusted_distance])
              else
                characteristics[:carrier_mode].transport_emission_factor
              end
            end

            quorum 'from mode, weight, and adjusted distance', :needs => [:mode, :weight, :adjusted_distance] do |characteristics|
              if characteristics[:mode].name == "courier"
                characteristics[:mode].transport_emission_factor / (characteristics[:weight] * characteristics[:adjusted_distance])
              else
                characteristics[:mode].transport_emission_factor
              end
            end
            
            quorum 'from carrier', :needs => :carrier do |characteristics|
              characteristics[:carrier].transport_emission_factor
            end
            
            quorum 'default' do
              Carrier.fallback.transport_emission_factor
            end
          end
          
          committee :adjusted_distance do
            quorum 'from distance, route inefficiency factor, and dogleg factor', :needs => [:distance, :route_inefficiency_factor, :dogleg_factor] do |characteristics|
              characteristics[:distance] * characteristics[:route_inefficiency_factor] * characteristics[:dogleg_factor]
            end
            
            quorum 'default' do
              3219 # ASSUMED: arbitrary
            end
          end
          
          committee :dogleg_factor do
            quorum 'from segment count', :needs => :segment_count do |characteristics|
              if characteristics[:segment_count] == 1
                1.0
              else
                1.8 # based on our sample FedEx tracking numbers
              end
            end
          end
          
          committee :route_inefficiency_factor do
            quorum 'from mode', :needs => :mode do |characteristics|
              characteristics[:mode].route_inefficiency_factor
            end
            
            quorum 'default' do
              Carrier.fallback.route_inefficiency_factor
            end
          end
            
          committee :distance do
            quorum 'by road', :needs => [:origin_location, :destination_location, :mode] do |characteristics|
              unless characteristics[:mode].name == 'air'
                mapquest = ::MapQuestDirections.new characteristics[:origin_location].ll, characteristics[:destination_location].ll
                mapquest.status.to_i == 0 ? mapquest.distance_in_miles.miles.to(:kilometres) : nil
              end
            end
            
            quorum 'as the crow flies', :needs => [:origin_location, :destination_location] do |characteristics|
              Mapper.distance_between(characteristics[:origin_location].ll, characteristics[:destination_location].ll, :units => :kms)
            end
          end
          
          committee :carrier_mode do
            quorum 'from carrier and mode', :needs => [:carrier, :mode] do |characteristics|
              CarrierMode.find_by_carrier_name_and_mode_name(characteristics[:carrier].name, characteristics[:mode].name)
            end
          end
          
          committee :segment_count do
            quorum 'default' do
              # ASSUMED based on the fact that FedEx has a hub-spoke system with central and regional distribution centers so seems reasonable for average package to go through four FedEx facilities
              5
            end
          end
          
          committee :destination_location do
            quorum 'from destination', :needs => :destination do |characteristics|
              location = Geokit::Geocoders::MultiGeocoder.geocode characteristics[:destination].to_s
              location.success ? location : nil
            end
          end
          
          committee :destination do
            # For backwards compatability
            quorum 'from destination zip code', :needs => :destination_zip_code do |characteristics|
              characteristics[:destination_zip_code]
            end
          end
          
          committee :origin_location do
            quorum 'from origin', :needs => :origin do |characteristics|
              location = Geokit::Geocoders::MultiGeocoder.geocode characteristics[:origin].to_s
              location.success ? location : nil
            end
          end
          
          committee :origin do
            # For backwards compatability
            quorum 'from origin zip code', :needs => :origin_zip_code do |characteristics|
              characteristics[:origin_zip_code]
            end
          end
          
          committee :package_count do
            quorum 'default' do
              1 # ASSUMED arbitrary
            end
          end
          
          committee :weight do
            quorum 'default' do
              3.4 # ASSUMED based on average FedEx air package weight of 7.5 lbs
            end
          end
        end
      end
      
      class Mapper
        include Geokit::Mappable
      end
    end
  end
end
