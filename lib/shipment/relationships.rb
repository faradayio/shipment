module BrighterPlanet
  module Shipment
    module Relationships
      def self.included(base)
        base.belongs_to :carrier,              :foreign_key => 'carrier_name',  :primary_key => 'name'
        base.belongs_to :origin_zip_code,      :foreign_key => 'zip_code_name', :primary_key => 'name', :class_name => 'ZipCode'
        base.belongs_to :destination_zip_code, :foreign_key => 'zip_code_name', :primary_key => 'name', :class_name => 'ZipCode'
        base.belongs_to :mode,                 :foreign_key => 'mode_name',     :primary_key => 'name', :class_name => 'ShipmentMode'
      end
    end
  end
end
