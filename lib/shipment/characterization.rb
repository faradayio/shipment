module BrighterPlanet
  module Shipment
    module Characterization
      def self.included(base)
        base.characterize do
          has :weight
          has :package_count
          has :shipping_company
          has :origin_zip_code
          has :destination_zip_code
          has :mode
        end
      end
    end
  end
end
