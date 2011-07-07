module BrighterPlanet
  module Shipment
    module Data
      def self.included(base)
        base.create_table do
          float   'weight'
          integer 'package_count'
          string  'carrier_name'
          string  'mode_name'
          integer 'segment_count'
          string  'origin'
          string  'destination'
          string  'origin_zip_code'      # For backwards compatability
          string  'destination_zip_code' # For backwards compatability
          float   'distance'
        end
      end
    end
  end
end
