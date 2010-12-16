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

  Scenario: Calculations from origin/destination zip code
    Given a shipment has "origin_zip_code" of "05753"
    And it has "destination_zip_code" of "05401"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "0.6"

  Scenario: Calculations from origin/destination
    Given a shipment has "origin" of "Lansing, MI"
    And it has "destination" of "Canterbury, Kent, UK"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "30.9"

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
      | mode    | origin      | destination          | emission |
      | courier | 05753       | 05401                | 2.3      |
      | courier | Lansing, MI | Canterbury, Kent, UK | 2.3      |
      | ground  | 05753       | 05401                | 329.3    |
      | ground  | Lansing, MI | Canterbury, Kent, UK | 37899.0  |
      | air     | 05753       | 05401                | 1809.9   |
      | air     | Lansing, MI | Canterbury, Kent, UK | 208443.2 |
