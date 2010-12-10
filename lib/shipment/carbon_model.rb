# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

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
# Contributions to this carbon model are actively encouraged and warmly welcomed. This library includes a comprehensive test suite to ensure that your changes do not cause regressions. All changes should include test coverage for new functionality. Please see [sniff](http://github.com/brighterplanet/sniff#readme), our emitter testing framework, for more information.
module BrighterPlanet
  module Shipment
    module CarbonModel
      def self.included(base)
        base.decide :emission, :with => :characteristics do
          committee :emission do
            # FIXME TODO deal with timeframe
            quorum 'from transport emission and corporate emission', :needs => [:transport_emission, :corporate_emission] do |characteristics|
              characteristics[:transport_emission] + characteristics[:corporate_emission]
            end
          end
          
          committee :corporate_emission do
            quorum 'from package count and corporate emission factor', :needs => [:package_count, :corporate_emission_factor] do |characteristics|
              if characteristics[:package_count] > 0
                characteristics[:package_count] * characteristics[:corporate_emission_factor]
              else
                raise "Invalid package_count: #{:package_count} (must be > 0)"
              end
            end
          end
          
          committee :transport_emission do
            quorum 'from mode, weight, adjusted distance, and transport emission factor', :needs => [:mode, :weight, :adjusted_distance, :transport_emission_factor] do |characteristics|
              # we're assuming here that the number of stops, rather than number of packages carried, is limiting factor on local delivery routes
              if characteristics[:mode].name == "courier"
                characteristics[:transport_emission_factor]
              elsif characteristics[:weight] > 0
                characteristics[:weight] * characteristics[:adjusted_distance] * characteristics[:transport_emission_factor]
              else
                raise "Invalid weight: #{:weight} (must be > 0)"
              end
            end
          end
          
          committee :corporate_emission_factor do
            quorum 'from carrier', :needs => :carrier, do |characteristics|
              characteristics[:carrier].corporate_emission_factor
            end
          end
          
          committee :transport_emission_factor do
            quorum 'from mode', :needs => :mode do |characteristics|
              characteristics[:mode].transport_emission_factor
            end
          end
          
          committee :adjusted_distance do
            quorum 'from distance, route inefficiency factor, and dogleg factor', :needs => [:distance, :route_inefficiency_factor, :dogleg_factor] do |characteristics|
              characteristics[:distance] * characteristics[:route_inefficiency_factor] * characteristics[:dogleg_factor]
            end
            
            quorum 'default' do
              # ASSUMED: arbitrary
              3219
            end
          end
            
          committee :dogleg_factor do
            quorum 'from segment count', :needs => :segment_count do |characteristics|
              if characteristics[:segment_count] > 0
                # ASSUMED arbitrary
                1.5 ** (characteristics[:segment_count] - 1)
              else
                raise "Invalid segment_count: #{:segment_count} (must be > 0)"
              end
            end
          end
          
          committee :route_inefficiency_factor do
            quorum 'from mode', :needs => :mode do |characteristics|
              characteristics[:mode].route_inefficiency_factor
            end
          end
          
          committee :distance do
            quorum 'from origin zip code, destination zip code, and mode', :needs => [:origin_zip_code, :destination_zip_code], do |characteristics|
              if characteristics[:origin_zip_code] == characteristics[:destination_zip_code]
                # FIXME TODO
                # Special calculation to deal with travel within the same zipcode
                0
              else
                characteristics[:origin_zip_code].distance_to(characteristics[:destination_zip_code], :units => :kms)
                # FIXME TODO: calculate the distance via road using map directions
              end
            end
          end
          
          committee :segment_count do
            quorum 'default' do
              # ASSUMED based on the fact that FedEx has a hub-spoke system with central and regional distribution centers so seems reasonable for average package to go through four FedEx facilities
              5
            end
          end
          
          committee :mode do
            quorum 'default' do
              ShipmentMode.fallback
            end
          end
          
          committee :carrier do
            quorum 'default' do
              Carrier.fallback
            end
          end
          
          committee :package_count do
            quorum 'default' do
              # ASSUMED arbitrary
              1
            end
          end
          
          committee :weight do
            quorum 'default' do
              # ASSUMED based on average FedEx air package weight of 7.5 lbs
              3.4
            end
          end
        end
      end
    end
  end
end
