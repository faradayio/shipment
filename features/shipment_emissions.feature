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
    And the geocoder will encode the origin_zip_code as "43.9968185,-73.1491165"
    And it has "destination_zip_code" of "05401"
    And the geocoder will encode the destination_zip_code as "44.4774456,-73.2163467"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "0.4"

  Scenario: Calculations from origin/destination
    Given a shipment has "origin" of "Lansing, MI"
    And the geocoder will encode the origin as "42.732535,-84.5555347"
    And it has "destination" of "Canterbury, Kent, UK"
    And the geocoder will encode the destination as "51.2772689,1.0805173"
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
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 1000.2   |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 1000.2   |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 |329.2    |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 37898.9  |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 1809.8   |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 208443.2 |

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
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 2600.0   |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 2600.0   |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 2158.0   |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 77297.4  |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 3671.5   |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 251631.5 |

  Scenario Outline: Calculations from everything
    Given a shipment has "weight" of "10.0"
    And it has "package_count" of "2.0"
    And it has "segment_count" of "1.0"
    And it has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 4100.0   |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 4100.0   |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 4075.2   |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 126852.0 |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 6548.1   |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 411711.6 |
