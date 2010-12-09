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
          ### Emission calculation
          # Returns the `emission` estimate (*kg CO<sub>2</sub>e*).
          # This is the total emission produced by the shipment venue.
          committee :emission do
            quorum 'from transport emission, intermodal emission, and corporate emission', :needs => [:transport_emission, :intermodal_emission, :corporate_emission] do |characteristics|
              characteristics[:transport_emission] + characteristics[:intermodal_emission] + characteristics[:corporate_emission]
            end
          end
          
          committee :corporate_emission do
            quorum 'from package count and corporate emission factor', :needs => [:package_count, :corporate_emission_factor] do |characteristics|
              characteristics[:package_count] * characteristics[:corporate_emission_factor]
            end
          end
          
          committee :intermodal_emission do
            quorum 'from weight and intermodal emission factor', :needs => [:weight, :intermodal_emission_factor] do |characteristics|
              characteristics[:weight] * characteristics[:intermodal_emission_factor]
            end
          end
          
          committee :transport_emission do
            quorum 'from weight, distance, and transport emission factor', :needs => [:weight, :distance, :transport_emission_factor] do |characteristics|
              characteristics[:weight] * characteristics[:distance] * characteristics[:transport_emission_factor]
            end
          end
          
          committee :corporate_emission_factor do
            quorum 'from shipping company', :needs => :shipping_company, do |characteristics|
              characteristics[:shipping_company].corporate_emission_factor
            end
          end
          
          committee :intermodal_emission_factor do
            quorum 'from mode', :needs => :mode, do |characteristics|
              characteristics[:mode].intermodal_emission_factor
            end
          end
          
          committee :transport_emission_factor do
            quorum 'from mode', :needs => :mode, do |characteristics|
              characteristics[:mode].transport_emission_factor
            end
          end
          
          committee :distance do
            quorum 'from origin zip code, destination zip code, and mode', :needs => [:origin_zip_code, :destination_zip_code, :mode], do |characteristics|
              FIXME
            end
            
            quorum 'default' do
              FIXME
            end
          end
          
          committee :mode do
            quorum 'default' do
              ShipmentMode.find_by_name 'US average'
            end
          end
          
          committee :shipping_company do
            quorum 'default' do
              ShippingCompany.find_by_name 'US average'
            end
          end
        end
      end
    end
  end
end
