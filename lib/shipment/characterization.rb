module BrighterPlanet
  module Shipment
    module Characterization
      def self.included(base)
        base.characterize do
          has :weight, :measures => :mass
          has :package_count
          has :carrier
          has :mode
          has :segment_count
          has :origin
          has :destination
          has :country
          has :origin_zip_code      # for backwards compatability - note that this is a string, not a ZipCode
          has :destination_zip_code # for backwards compatability - note that this is a string, not a ZipCode
          has :distance, :measures => Measurement::BigLength
        end
      end
    end
  end
end
