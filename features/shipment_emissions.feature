Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "8.7"

  Scenario: Calculations from weight, package count, segment count
    Given a shipment has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment_count" of "1"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "25.4"

  Scenario Outline: Calculations from origin/destination
    Given a shipment has "origin" of "<origin>"
    And it has "destination" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | origin | destination                          | emission |
      | 05401  | 488 Haight Street, San Francisco, CA | 20.7     |
      | 05401  | Canterbury, Kent, UK                 | 26.8     |

  Scenario: Calculations from carrier
    Given a shipment has "carrier.name" of "FedEx"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "10.4"

  Scenario Outline: Calculations from mode
    Given a shipment has "mode.name" of "<mode>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 2.3      |
      | ground  | 10944.9  |
      | air     | 54723.3  |

  Scenario Outline: Calculations from mode and origin/destination
    Given a shipment has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And it has "destination" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin | destination                                   | emission     |
      | courier | 05753  | Address: 488 Haight Street, San Francisco, CA | 2.318        |
      | courier | 05753  | Address: Canterbury, Kent, UK                 | 2.318        |
      | ground  | 05753  | Address: 488 Haight Street, San Francisco, CA | 25345.6      |
      | ground  | 05753  | Address: Canterbury, Kent, UK                 | 32950.9      |
      | air     | 05753  | Address: 488 Haight Street, San Francisco, CA | 139399.3     |
      | air     | 05753  | Address: Canterbury, Kent, UK                 | 181228.8     |
