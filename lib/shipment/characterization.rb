module BrighterPlanet
  module Shipment
    module Characterization
      def self.included(base)
        base.characterize do
          has :weight
          has :package_count
          has :carrier
          has :mode
          has :segment_count
          has :origin_zip_code
          has :destination_zip_code
          has :mapquest_api_key, :display => lambda { |key| "secret key" }
        end
      end
    end
  end
end
