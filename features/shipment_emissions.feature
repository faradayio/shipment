Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "6.0"

  Scenario: Calculations from weight, package count, segment count
    Given a shipment has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment_count" of "1"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "17.4"

  Scenario: Calculations from origin/destination zip code
    Given a shipment has "origin_zip_code" of "05753"
    And it has "destination_zip_code" of "05401"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "0.4"

  Scenario: Calculations from origin/destination
    Given a shipment has "origin" of "Lansing, MI"
    And it has "destination" of "Canterbury, Kent, UK"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "20.8"

  Scenario: Calculations from carrier
    Given a shipment has "carrier.name" of "FedEx"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "34333.8"

  Scenario Outline: Calculations from mode
    Given a shipment has "mode.name" of "<mode>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 1000.2   |
      | ground  | 10944.8  |
      | air     | 54723.2  |

  Scenario Outline: Calculations from carrier and mode
    Given a shipment has "mode.name" of "<mode>"
    And it has "carrier.name" of "FedEx"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 2600.0   |
      | ground  | 23389.2  |
      | air     | 67167.6  |

  Scenario Outline: Calculations from mode and origin/destination
    Given a shipment has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And it has "destination" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | destination          | emission |
      | courier | 05753       | 05401                | 1000.2   |
      | courier | Lansing, MI | Canterbury, Kent, UK | 1000.2   |
      | ground  | 05753       | 05401                | 329.2    |
      | ground  | Lansing, MI | Canterbury, Kent, UK | 37898.9  |
      | air     | 05753       | 05401                | 1809.8   |
      | air     | Lansing, MI | Canterbury, Kent, UK | 208443.2 |

  Scenario Outline: Calculations from mode and carrier
    Given a shipment has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 2600.0   |
      | ground  | 23389.2  |
      | air     | 67167.6  |

  Scenario Outline: Calculations from mode, carrier, and origin/destination
    Given a shipment has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And it has "destination" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | destination          | emission |
      | courier | 05753       | 05401                | 2600.0   |
      | courier | Lansing, MI | Canterbury, Kent, UK | 2600.0   |
      | ground  | 05753       | 05401                | 2158.0   |
      | ground  | Lansing, MI | Canterbury, Kent, UK | 77297.4  |
      | air     | 05753       | 05401                | 3671.5   |
      | air     | Lansing, MI | Canterbury, Kent, UK | 251631.5 |

  Scenario Outline: Calculations from everything
    Given a shipment has "weight" of "10.0"
    And it has "package_count" of "2.0"
    And it has "segment_count" of "1.0"
    And it has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And it has "destination" of "<destination>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | destination          | emission |
      | courier | 05753       | 05401                | 4100.0   |
      | courier | Lansing, MI | Canterbury, Kent, UK | 4100.0   |
      | ground  | 05753       | 05401                | 4075.2   |
      | ground  | Lansing, MI | Canterbury, Kent, UK | 126852.0 |
      | air     | 05753       | 05401                | 6548.1   |
      | air     | Lansing, MI | Canterbury, Kent, UK | 411711.6 |
