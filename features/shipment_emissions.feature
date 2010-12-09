Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "FIXME"
