Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "32835.8"

  Scenario: Calculations from weight, package count, segment count
    Given a shipment has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment_count" of "1"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "96574.0"

  Scenario Outline: Calculations from origin/destination
    Given a shipment has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | origin | destination | emission |
      | 05401  | 05401       | 0.318    |
      | 05401  | 94128       | 224106.1 |

  Scenario: Calculations from carrier
    Given a shipment has "carrier.name" of "FedEx"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "32835.8"

  Scenario Outline: Calculations from mode
    Given a shipment has "mode.name" of "<mode>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 4.0      |
      | ground  | 10946.6  |
      | air     | 54725.0  |

  Scenario Outline: Calculations from mode and origin/destination
    Given a shipment has "mode.name" of "<mode>"
    And it has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin | destination | emission |
      | courier | 05401  | 05401       | 99999.9  |
      | courier | 05401  | 94128       | 99999.9  |
      | ground  | 05401  | 05401       | 99999.9  |
      | ground  | 05401  | 94128       | 99999.9  |
      | air     | 05401  | 05401       | 99999.9  |
      | air     | 05401  | 94128       | 391297.9 |
