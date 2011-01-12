Feature: Shipment Committee Calculations
  The shipment model should generate correct committee calculations

  Scenario: Weight from default
    Given a shipment emitter
    When the "weight" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.4"
  
  Scenario: Package count from default
    Given a shipment emitter
    When the "package_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"
  
  Scenario Outline: Origin from zip code
    Given a shipment emitter
    And a characteristic "origin_zip_code" of "<zip>"
    When the "origin" committee is calculated
    Then the committee should have used quorum "from origin zip code"
    And the conclusion of the committee should be "<origin>"
    Examples:
      | zip   | origin |
      | 05753 | 05753  |
      | 00000 | 00000  |

  Scenario Outline: Origin location from geocodeable origin
    Given a shipment emitter
    And a characteristic "origin" of address value "<origin>"
    And the geocoder will encode the origin as "<geocode>"
    When the "origin_location" committee is calculated
    Then the committee should have used quorum "from origin"
    And the conclusion of the committee should be "<location>"
    Examples:
      | origin                               | geocode                 | location                |
      | 05753                                | 43.9968185,-73.1491165  | 43.9968185,-73.1491165  |
      | San Francisco, CA                    | 37.7749295,-122.4194155 | 37.7749295,-122.4194155 |
      | 488 Haight Street, San Francisco, CA | 37.7722302,-122.4303328 | 37.7722302,-122.4303328 |
      | Canterbury, Kent, UK                 | 51.2772689,1.0805173    | 51.2772689,1.0805173    |

  Scenario: Origin location from non-geocodeable origin
    Given a shipment emitter
    And a characteristic "origin" of "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    And the geocoder will encode the origin as ","
    When the "origin_location" committee is calculated
    Then the conclusion of the committee should be nil
    
  Scenario Outline: Destination from zip code
    Given a shipment emitter
    And a characteristic "destination_zip_code" of "<zip>"
    When the "destination" committee is calculated
    Then the committee should have used quorum "from destination zip code"
    And the conclusion of the committee should be "<destination>"
    Examples:
      | zip   | destination |
      | 05401 | 05401       |
      | 00000 | 00000       |

  Scenario Outline: Destination location from geocodeable destination
    Given a shipment emitter
    And a characteristic "destination" of "<destination>"
    And the geocoder will encode the destination as "<geocode>"
    When the "destination_location" committee is calculated
    Then the committee should have used quorum "from destination"
    And the conclusion of the committee should be "<location>"
    Examples:
      | destination                          | geocode                 | location                |
      | 05753                                | 43.9968185,-73.1491165  | 43.9968185,-73.1491165  |
      | San Francisco, CA                    | 37.7749295,-122.4194155 | 37.7749295,-122.4194155 |
      | 488 Haight Street, San Francisco, CA | 37.7722302,-122.4303328 | 37.7722302,-122.4303328 |
      | Canterbury, Kent, UK                 | 51.2772689,1.0805173    | 51.2772689,1.0805173    |

  Scenario: Destination location from non-geocodeable origin
    Given a shipment emitter
    And a characteristic "destination" of "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    And the geocoder will encode the destination as ","
    When the "destination_location" committee is calculated
    Then the conclusion of the committee should be nil

  Scenario: Segment count from default
    Given a shipment emitter
    When the "segment_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "5"

  Scenario: Carrier mode from carrier and mode
    Given a shipment emitter
    And a characteristic "carrier.name" of "FedEx"
    And a characteristic "mode.name" of "ground"
    When the "carrier_mode" committee is calculated
    Then the committee should have used quorum "from carrier and mode"
    And the conclusion of the committee should have "name" of "FedEx ground"

  Scenario Outline: Distance by road from locations and mode
    Given a shipment emitter
    And a characteristic "origin_location" of "<origin>"
    And a characteristic "destination_location" of "<destination>"
    And a characteristic "mode.name" of "<mode>"
    And a characteristic "mapquest_api_key" of "ABC123"
    And mapquest determines the distance to be "<mapquest_distance>"
    When the "distance" committee is calculated
    Then the committee should have used quorum "by road"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | mode    | mapquest_distance | distance |
      | 43,-73 | 43.-73      | ground  | 0.0               | 0.0      |
      | 43,-73 | 43.1,-73    | ground  | 57.93638          | 57.93638 |
      | 43,-73 | 43,-73      | courier | 0.0               | 0.0      |
      | 43,-73 | 43.1,-73    | courier | 57.93638          | 57.93638 |

  Scenario: Distance by road from undriveable locations and mode
    Given a shipment emitter
    And a characteristic "origin" of "Lansing, MI"
    And a characteristic "destination" of "Canterbury, Kent, UK"
    And a characteristic "mode.name" of "ground"
    And a characteristic "mapquest_api_key" of "ABC123"
    When the "origin_location" committee is calculated
    And the "destination_location" committee is calculated
    And the "distance" committee is calculated
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "6192.60039"

  Scenario Outline: Distance as the crow flies from locations and mode
    Given a shipment emitter
    And a characteristic "origin_location" of "<origin>"
    And a characteristic "destination_location" of "<destination>"
    And a characteristic "mode.name" of "air"
    And a characteristic "mapquest_api_key" of "ABC123"
    When the "distance" committee is calculated
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin                 | destination            | distance   |
      | 43.9968185,-73.1491165 | 44.4774456,-73.2163467 | 53.75967   |
      | 42.732535,-84.5555347  | 51.2772689,1.0805173   | 6192.60039 |
  
  Scenario: Distance as the crow flies from locations
    Given a shipment emitter
    And a characteristic "origin_location" of "43.9968185,-73.1491165"
    And a characteristic "destination_location" of "44.4774456,-73.2163467"
    When the "distance" committee is calculated
    Then the committee should have used quorum "as the crow flies"
    And the conclusion of the committee should be "53.75967"

  Scenario: Route inefficiency factor from default
    Given a shipment emitter
    When the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1.03"

  Scenario Outline: Route inefficiency factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | mode    | factor |
      | courier | 1.0    |
      | ground  | 1.0    |
      | air     | 1.1    |

  Scenario Outline: Dogleg factor from segment count
    Given a shipment emitter
    And a characteristic "segment_count" of "<segments>"
    When the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | segments | factor |
      | 1        | 1.0    |
      | 2        | 1.8    |
      | -1       | 1.8    |

  Scenario: Adjusted distance from default
    Given a shipment emitter
    When the "adjusted_distance" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3219.0"

  Scenario: Adjusted distance from distance, route inefficiency factor, and dogleg factor
    Given a shipment emitter
    And a characteristic "distance" of "100.0"
    And a characteristic "route_inefficiency_factor" of "2.0"
    And a characteristic "dogleg_factor" of "2.0"
    When the "adjusted_distance" committee is calculated
    Then the committee should have used quorum "from distance, route inefficiency factor, and dogleg factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Transport emission factor from default
    Given a shipment emitter
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.0005266"

  Scenario Outline: Transport emission factor from carrier
    Given a shipment emitter
    And a characteristic "carrier.name" of "FedEx"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "0.008"

  Scenario Outline: Transport emission factor from mode, weight, and adjusted distance
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    And a characteristic "weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode, weight, and adjusted distance"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode    | weight | adjusted_distance | emission_factor |
      | courier | 2.0    | 5.0               | 0.5             |
      | ground  | 2.0    | 50.0              | 0.0002          |
      | air     | 2.0    | 50.0              | 0.002           |

  Scenario Outline: Transport emission factor from carrier mode, weight, and adjusted distance
    Given a shipment emitter
    And a characteristic "carrier_mode.name" of "<carrier_mode>"
    And a characteristic "weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier mode, weight, and adjusted distance"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | carrier_mode    | weight | adjusted_distance | emission_factor |
      | FedEx courier   | 2.0    | 5.0               | 0.2             |
      | FedEx ground    | 2.0    | 50.0              | 0.0001          |
      | FedEx air       | 2.0    | 50.0              | 0.001           |

  Scenario: Corporate emission factor from default
    Given a shipment emitter
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.221"

  Scenario: Corporate emission factor from carrier
    Given a shipment emitter
    And a characteristic "carrier.name" of "FedEx"
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "0.3"

  Scenario: Transport emission from weight, adjusted distance, and transport emission factor
    Given a shipment emitter
    And a characteristic "weight" of "2.0"
    And a characteristic "adjusted_distance" of "100.0"
    And a characteristic "transport_emission_factor" of "2.0"
    When the "transport_emission" committee is calculated
    Then the committee should have used quorum "from weight, adjusted distance, and transport emission factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Corporate emission from package count and corporate emission factor
    Given a shipment emitter
    And a characteristic "package_count" of "2"
    And a characteristic "corporate_emission_factor" of "2.0"
    When the "corporate_emission" committee is calculated
    Then the committee should have used quorum "from package count and corporate emission factor"
    And the conclusion of the committee should be "4.0"

  Scenario: Emission from transport emission and corporate emission
    Given a shipment emitter
    And a characteristic "transport_emission" of "400.0"
    And a characteristic "corporate_emission" of "20.0"
    When the "emission" committee is calculated
    Then the committee should have used quorum "from transport emission and corporate emission"
    And the conclusion of the committee should be "420.0"
