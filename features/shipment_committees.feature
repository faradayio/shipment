Feature: Shipment Committee Calculations
  The shipment model should generate correct committee calculations

  Background:
    Given a shipment

  Scenario: Weight from default
    When the "weight" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.4"
  
  Scenario: Package count from default
    When the "package_count" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"
    Given the conclusion of the committee should be "1"
  
  Scenario Outline: Origin from zip code
    Given a characteristic "origin_zip_code" of "<zip>"
    When the "origin" committee reports
    Then the committee should have used quorum "from origin zip code"
    And the conclusion of the committee should be "<origin>"
    Examples:
      | zip   | origin |
      | 05753 | 05753  |
      | 00000 | 00000  |

  Scenario Outline: Origin location from geocodeable origin
    Given a characteristic "origin" of address value "<origin>"
    And the geocoder will encode the origin as "<lat_lng>"
    When the "origin_location" committee reports
    Then the committee should have used quorum "from origin"
    And the conclusion of the committee should be located at "<location>"
    Examples:
      | origin                               | lat_lng                 | location                |
      | 05753                                | 44.0229305,-73.1450146  | 44.0229305,-73.1450146  |
      | San Francisco, CA                    | 37.7749295,-122.4194155 | 37.7749295,-122.4194155 |
      | 488 Haight Street, San Francisco, CA | 37.7722537,-122.4302052 | 37.7722537,-122.4302052 |
      | Canterbury, Kent, UK                 | 51.280233,1.0789089     | 51.280233,1.0789089     |

  Scenario: Origin location from non-geocodeable origin
    Given a characteristic "origin" of address value "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    And the geocoder will encode the origin as ""
    When the "origin_location" committee reports
    Then the conclusion of the committee should be nil

  Scenario Outline: Destination from zip code
    Given a characteristic "destination_zip_code" of "<zip>"
    When the "destination" committee reports
    Then the committee should have used quorum "from destination zip code"
    And the conclusion of the committee should be "<destination>"
    Examples:
      | zip   | destination |
      | 05401 | 05401       |
      | 00000 | 00000       |

  Scenario Outline: Destination location from geocodeable destination
    Given a characteristic "destination" of address value "<destination>"
    And the geocoder will encode the destination as "<lat_lng>"
    When the "destination_location" committee reports
    Then the committee should have used quorum "from destination"
    And the conclusion of the committee should be located at "<location>"
    Examples:
      | destination                          | lat_lng                 | location                |
      | 05753                                | 44.0229305,-73.1450146  | 44.0229305,-73.1450146  |
      | San Francisco, CA                    | 37.7749295,-122.4194155 | 37.7749295,-122.4194155 |
      | 488 Haight Street, San Francisco, CA | 37.7722537,-122.4302052 | 37.7722537,-122.4302052 |
      | Canterbury, Kent, UK                 | 51.280233,1.0789089     | 51.280233,1.0789089     |

  Scenario: Destination location from non-geocodeable destination
    Given a characteristic "destination" of address value "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    And the geocoder will encode the destination as ""
    When the "destination_location" committee reports
    Then the conclusion of the committee should be nil

  Scenario: Segment count from default
    When the "segment_count" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "5"

  Scenario: Carrier mode from carrier and mode
    Given a characteristic "carrier.name" of "FedEx"
    And a characteristic "mode.name" of "ground"
    When the "carrier_mode" committee reports
    Then the committee should have used quorum "from carrier and mode"
    And the conclusion of the committee should have "name" of "FedEx ground"

  Scenario Outline: Distance by road from locations and mode
    Given a characteristic "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin>"
    And a characteristic "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination>"
    And a characteristic "mode.name" of "<mode>"
    And mapquest determines the distance in miles to be "<mq_dist>"
    When the "origin_location" committee reports
    And the "destination_location" committee reports
    And the "distance" committee reports
    Then the committee should have used quorum "by road"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin     | destination | mode    | mq_dist | distance |
      | 43.0,-73.0 | 43.0,-73.0  | ground  | 0.0     | 0.0      |
      | 43.0,-73.0 | 43.1,-73.0  | ground  | 38.0    | 61.15507 |
      | 43.0,-73.0 | 43.0,-73.0  | courier | 0.0     | 0.0      |
      | 43.0,-73.0 | 43.1,-73.0  | courier | 38.0    | 61.15507 |

  Scenario: Distance by road from undriveable locations and mode
    Given a characteristic "origin" of "Lansing, MI"
    And the geocoder will encode the origin as "42.732535,-84.5555347"
    And a characteristic "destination" of "Canterbury, Kent, UK"
    And the geocoder will encode the destination as "51.280233,1.0789089"
    And a characteristic "mode.name" of "ground"
    And mapquest determines the distance in miles to be ""
    When the "origin_location" committee reports
    And the "destination_location" committee reports
    And the "distance" committee reports
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "6186.74309"

  Scenario Outline: Distance as the crow flies from locations and mode
    Given a characteristic "origin" of "<origin>"
    And the geocoder will encode the origin as "<origin>"
    And a characteristic "destination" of "<destination>"
    And the geocoder will encode the destination as "<destination>"
    And a characteristic "mode.name" of "air"
    When the "origin_location" committee reports
    And the "destination_location" committee reports
    And the "distance" committee reports
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin                 | destination            | distance   |
      | 43.99786,  -73.146935  | 44.477208, -73.216204  |   53.58596 |
      | 42.7325346,-84.5554643 | 51.2773103,  1.0804506 | 6186.98385 |
  
  Scenario: Distance as the crow flies from locations
    Given a characteristic "origin" of "Middlebury, VT"
    And the geocoder will encode the origin as "44.0153291,-73.1673508"
    And a characteristic "destination" of "Burlington, VT"
    And the geocoder will encode the destination as "44.4758825,-73.212072"
    When the "origin_location" committee reports
    And the "destination_location" committee reports
    And the "distance" committee reports
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "51.33495"

  Scenario: Route inefficiency factor from default
    When the "route_inefficiency_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1.03"

  Scenario Outline: Route inefficiency factor from mode
    Given a characteristic "mode.name" of "<mode>"
    When the "route_inefficiency_factor" committee reports
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | mode    | factor |
      | courier | 1.0    |
      | ground  | 1.0    |
      | air     | 1.1    |

  Scenario Outline: Dogleg factor from segment count
    Given a characteristic "segment_count" of "<segments>"
    When the "dogleg_factor" committee reports
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | segments | factor |
      | 1        | 1.0    |
      | 2        | 1.8    |
      | -1       | 1.8    |

  Scenario: Adjusted distance from default
    When the "adjusted_distance" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3219.0"

  Scenario: Adjusted distance from distance, route inefficiency factor, and dogleg factor
    Given a characteristic "distance" of "100.0"
    And a characteristic "route_inefficiency_factor" of "2.0"
    And a characteristic "dogleg_factor" of "2.0"
    When the "adjusted_distance" committee reports
    Then the committee should have used quorum "from distance, route inefficiency factor, and dogleg factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Transport emission factor from default
    When the "transport_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.0005266"

  Scenario: Transport emission factor from carrier
    Given a characteristic "carrier.name" of "FedEx"
    When the "transport_emission_factor" committee reports
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "0.0008"

  Scenario Outline: Transport emission factor from mode, weight, and adjusted distance
    Given a characteristic "mode.name" of "<mode>"
    And a characteristic "weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    When the "transport_emission_factor" committee reports
    Then the committee should have used quorum "from mode, weight, and adjusted distance"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode    | weight | adjusted_distance | emission_factor |
      | courier | 2.0    | 5.0               | 0.5             |
      | ground  | 2.0    | 50.0              | 0.0002          |
      | air     | 2.0    | 50.0              | 0.002           |

  Scenario Outline: Transport emission factor from carrier mode, weight, and adjusted distance
    Given a characteristic "carrier_mode.name" of "<carrier_mode>"
    And a characteristic "weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    When the "transport_emission_factor" committee reports
    Then the committee should have used quorum "from carrier mode, weight, and adjusted distance"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | carrier_mode    | weight | adjusted_distance | emission_factor |
      | FedEx courier   | 2.0    | 5.0               | 0.2             |
      | FedEx ground    | 2.0    | 50.0              | 0.0001          |
      | FedEx air       | 2.0    | 50.0              | 0.001           |

  Scenario: Corporate emission factor from default
    When the "corporate_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.221"

  Scenario: Corporate emission factor from carrier
    Given a characteristic "carrier.name" of "FedEx"
    When the "corporate_emission_factor" committee reports
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "0.3"

  Scenario: Transport emission from weight, adjusted distance, and transport emission factor
    Given a characteristic "weight" of "2.0"
    And a characteristic "adjusted_distance" of "100.0"
    And a characteristic "transport_emission_factor" of "2.0"
    When the "transport_emission" committee reports
    Then the committee should have used quorum "from weight, adjusted distance, and transport emission factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Corporate emission from package count and corporate emission factor
    Given a characteristic "package_count" of "2"
    And a characteristic "corporate_emission_factor" of "2.0"
    When the "corporate_emission" committee reports
    Then the committee should have used quorum "from package count and corporate emission factor"
    And the conclusion of the committee should be "4.0"

  Scenario: Emission from transport emission and corporate emission
    Given a characteristic "transport_emission" of "400.0"
    And a characteristic "corporate_emission" of "20.0"
    When the "carbon" committee reports
    Then the committee should have used quorum "from transport emission and corporate emission"
    And the conclusion of the committee should be "420.0"
