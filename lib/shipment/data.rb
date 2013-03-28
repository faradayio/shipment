module BrighterPlanet
  module Shipment
    module Data
      def self.included(base)
        base.col :weight, :type => :float
        base.col :package_count, :type => :integer
        base.col :carrier_name
        base.col :mode_name
        base.col :segment_count, :type => :integer
        base.col :origin
        base.col :destination
        base.col :origin_zip_code      # For backwards compatability
        base.col :destination_zip_code # For backwards compatability
        base.col :country_iso_3166_code
        base.col :distance, :type => :float
      end
    end
  end
end
