Feature: Shipment Emissions Calculations
  The shipment model should generate correct emission calculations

  Background:
    Given a shipment

  Scenario: Calculations starting from nothing
    Given a shipment has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "6.0"

  Scenario: Calculations from weight, package count, segment count, and distance
    Given it has "weight" of "10"
    And it has "package_count" of "2"
    And it has "segment_count" of "1"
    And it has "distance" of "1000"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "5.9"

  Scenario: Calculations from origin/destination zip code
    Given it has "origin_zip_code" of "05753"
    And the geocoder will encode the origin_zip_code as "43.9968185,-73.1491165"
    And it has "destination_zip_code" of "05401"
    And the geocoder will encode the destination_zip_code as "44.4774456,-73.2163467"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "0.4"

  Scenario: Calculations from origin/destination
    Given it has "origin" of "Lansing, MI"
    And the geocoder will encode the origin as "42.732535,-84.5555347"
    And it has "destination" of "Canterbury, Kent, UK"
    And the geocoder will encode the destination as "51.2772689,1.0805173"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "20.8"

  Scenario: Calculations from carrier
    Given it has "carrier.name" of "FedEx"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "9.1"

  Scenario Outline: Calculations from mode
    Given it has "mode.name" of "<mode>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 5.2      |
      | ground  | 2.4      |
      | air     | 22.1     |

  Scenario Outline: Calculations from carrier and mode
    Given it has "mode.name" of "<mode>"
    And it has "carrier.name" of "FedEx"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | emission |
      | courier | 2.3      |
      | ground  | 1.4      |
      | air     | 11.2     |

  Scenario Outline: Calculations from mode and origin/destination
    Given it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 5.2      |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 5.2      |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 0.3      |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 7.8      |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 0.9      |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 83.6     |

  Scenario Outline: Calculations from mode, carrier, and origin/destination
    Given it has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 2.3      |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 2.3      |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 0.3      |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 4.1      |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 0.7      |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 42.0     |

  Scenario Outline: Calculations from everything
    Given it has "weight" of "10.0"
    And it has "package_count" of "2.0"
    And it has "segment_count" of "1.0"
    And it has "carrier.name" of "FedEx"
    And it has "mode.name" of "<mode>"
    And it has "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin_location>"
    And it has "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination_location>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.1" kgs of "<emission>"
    Examples:
      | mode    | origin      | origin_location        | destination          | destination_location   | emission |
      | courier | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 2.6      |
      | courier | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 2.6      |
      | ground  | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 0.7      |
      | ground  | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 6.8      |
      | air     | 05753       | 43.9968185,-73.1491165 | 05401                | 44.4774456,-73.2163467 | 1.2      |
      | air     | Lansing, MI | 42.732535,-84.5555347  | Canterbury, Kent, UK | 51.2772689,1.0805173   | 68.7     |
