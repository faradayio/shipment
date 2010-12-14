Feature: Shipment Committee Calculations
  The shipment model should generate correct committee calculations

  Scenario: Weight from nothing
    Given a shipment emitter
    When the "weight" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.4"
  
  Scenario: Package count from nothing
    Given a shipment emitter
    When the "package_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"
  
  Scenario: Segment count from nothing
    Given a shipment emitter
    When the "segment_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "5"

  Scenario Outline: Distance from same locality
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    And a characteristic "destination" of "<destination>"
    When the "origin_location" committee is calculated
    And the "destination_location" committee is calculated
    And the "distance" committee is calculated
    Then the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | distance |
      | 05753  | 05753       | 0        |
  
  Scenario Outline: Distance from mapquest
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    And a characteristic "destination" of "<destination>"
    And a characteristic "mode.name" of "ground"
    And a characteristic "mapquest_api_key" of "ABC123"
    And mapquest determines the distance to be "<mapquest_distance>"
    When the "origin_location" committee is calculated
    And the "destination_location" committee is calculated
    And the "distance" committee is calculated
    Then the committee should have used quorum "from mapquest"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | mapquest_distance | distance |
      | 05753  | 05401       | 53                | 53       |
      | 05753  | 05401       | 33                | 33       |

  Scenario Outline: Distance from direct path
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    And a characteristic "destination" of "<destination>"
    And a characteristic "mode.name" of "air"
    And a characteristic "mapquest_api_key" of "ABC123"
    When the "origin_location" committee is calculated
    And the "destination_location" committee is calculated
    And the "distance" committee is calculated
    Then the committee should have used quorum "from direct path"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin      | destination          | distance   |
      | 05753       | San Francisco, CA    | 4140.39274 |
      | Lansing, MI | Canterbury, Kent, UK | 6192.60039 |
      | 05753       | Canterbury, Kent, UK | 5384.08989 |
  
  Scenario Outline: Origin location from origin
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    When the "origin_location" committee is calculated
    Then the committee should have used quorum "from origin"
    And the conclusion of the committee should be "<location>"
    Examples:
      | origin                                         | location                |
      | 05753                                          | 43.9968185,-73.1491165  |
      | Address: San Francisco, CA                     | 37.7749295,-122.4194155 |
      | Address: 488 Haight Street, San Francisco, CA  | 37.7721568,-122.4302295 |
      | Address: Canterbury, Kent, UK                  | 51.2772689,1.0805173    |

  Scenario Outline: Origin location from origin_zip_code
    Given a shipment emitter
    And a characteristic "origin_zip_code" of "<origin>"
    When the "origin" committee is calculated
    And the "origin_location" committee is calculated
    Then the conclusion of the committee should be "<location>"
    Examples:
      | origin                                         | location                |
      | 05753                                          | 43.9968185,-73.1491165  |
  
  Scenario Outline: Destination location from destination
    Given a shipment emitter
    And a characteristic "destination" of "<destination>"
    When the "destination_location" committee is calculated
    Then the committee should have used quorum "from destination"
    And the conclusion of the committee should be "<location>"
    Examples:
      | destination                                    | location                |
      | 05753                                          | 43.9968185,-73.1491165  |
      | Address: 488 Haight Street, San Francisco, CA  | 37.7721568,-122.4302295 |
      | Address: Canterbury, Kent, UK                  | 51.2772689,1.0805173    |
  
  Scenario Outline: Destination location from destination_zip_code
    Given a shipment emitter
    And a characteristic "destination_zip_code" of "<destination>"
    When the "destination" committee is calculated
    And the "destination_location" committee is calculated
    Then the conclusion of the committee should be "<location>"
    Examples:
      | destination | location                |
      | 05753       | 43.9968185,-73.1491165  |

  Scenario: Origin committee from uncodable origin
    Given a shipment emitter
    And a characteristic "origin" of "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    When the "origin_location" committee is calculated
    Then the conclusion of the committee should be nil
  
  Scenario: Destination committee from uncodable destination
    Given a shipment emitter
    And a characteristic "destination" of "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    When the "destination_location" committee is calculated
    Then the conclusion of the committee should be nil

  Scenario: Route inefficiency factor from default
    Given a shipment emitter
    When the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1.05"

  Scenario Outline: Route inefficiency factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | mode    | factor |
      | courier | 5.0    |
      | ground  | 1.0    |
      | air     | 1.1    |

  Scenario: Dogleg factor from default segment count
    Given a shipment emitter
    When the "segment_count" committee is calculated
    And the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "5.0625"

  Scenario Outline: Dogleg factor from segment count
    Given a shipment emitter
    And a characteristic "segment_count" of "<segments>"
    When the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | segments | factor |
      | 1        | 1.0    |
      | 2        | 1.5    |

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
    And the conclusion of the committee should be "0.00076955"

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
      | courier | 2.0    | 5.0               | 0.2             |
      | ground  | 2.0    | 50.0              | 1.0             |
      | air     | 2.0    | 50.0              | 5.0             |

  Scenario: Corporate emission factor from default
    Given a shipment emitter
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.318"

  Scenario: Corporate emission factor from carrier
    Given a shipment emitter
    And a characteristic "carrier.name" of "FedEx"
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "2.0"

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
