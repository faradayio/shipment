Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "8.7"

  Scenario: Calculations from weight, package count and segment count
    Given a shipment has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment" of "true"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "25.4"

  Scenario Outline: Calculations from origin/destination
    Given a shipment has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    And mapquest determines the distance to be "<distance>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | origin | destination | mapquest_distance | emission |
      | 05401  | 05401       |                   | 0.3      |
      | 05401  | 94128       | 30                | 20.8     |

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
    And it has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin | destination | emission |
      | courier | 05401  | 05401       | 2.3      |
      | ground  | 05401  | 05401       | 0.3      |
      | air     | 05401  | 05401       | 0.3      |
      | courier | 05401  | 94128       | 2.3      |
      | ground  | 05401  | 94128       | 25296.2  |
      | air     | 05401  | 94128       | 139127.8 |
