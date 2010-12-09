module BrighterPlanet
  module Shipment
    module Data
      def self.included(base)
        base.data_miner do
          schema do
            float   'weight'
            integer 'package_count'
            string  'shipping_company_name'
            string  'mode_name'
            integer 'segment_count'
            string  'origin_zip_code_name'
            string  'destination_zip_code_name'
          end
          
          process :run_data_miner_on_belongs_to_associations
        end
      end
    end
  end
end
