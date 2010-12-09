module BrighterPlanet
  module Shipment
    module Characterization
      def self.included(base)
        base.characterize do
          has :weight
          has :package_count
          has :shipping_company
          has :mode
          has :segment_count
          has :origin_zip_code
          has :destination_zip_code
        end
      end
    end
  end
end
