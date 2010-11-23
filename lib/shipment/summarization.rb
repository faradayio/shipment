module BrighterPlanet
  module Shipment
    module Summarization
      def self.included(base)
        base.summarize do |has|
        end
      end
    end
  end
end
