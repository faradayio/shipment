Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "32836.8"

  Scenario: Calculations from weight, package count, segment count
    Given a shipment has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment_count" of "1"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "96576.0"

  Scenario Outline: Calculations from origin/destination
    Given a shipment has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | origin | destination | emission |
      | 05401  | 05401       | 99999.9  |
      | 05401  | 94128       | 99999.9  |

  Scenario: Calculations from shipping company
    Given a shipment has "shipping_company.name" of "FedEx"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "32835.8"

  Scenario Outline: Calculations from mode
    Given a shipment has "mode.name" of "<mode>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode            | emission |
      | ground courrier | 5.0      |
      | ground carrier  | 10947.6  |
      | air transport   | 54726.0  |

  Scenario Outline: Calculations from mode and origin/destination
    Given a shipment has "mode.name" of "<mode>"
    And it has "origin_zip_code.name" of "<origin>"
    And it has "destination_zip_code.name" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode            | origin | destination | emission |
      | ground courrier | 05401  | 05401       | 99999.9  |
      | ground courrier | 05401  | 94128       | 99999.9  |
      | ground carrier  | 05401  | 05401       | 99999.9  |
      | ground carrier  | 05401  | 94128       | 99999.9  |
      | air transport   | 05401  | 05401       | 99999.9  |
      | air transport   | 05401  | 94128       | 391298.9 |
