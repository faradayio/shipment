Feature: Shipment Committee Calculations
  The shipment model should generate correct committee calculations

  Scenario: Verified weight from nothing
    Given a shipment emitter
    When the "verified_weight" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.4"
  
  Scenario: Verified weight from invalid weight
    Given a shipment emitter
    And a characteristic "weight" of "0.0"
    When the "verified_weight" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.4"

  Scenario: Verified weight from valid weight
    Given a shipment emitter
    And a characteristic "weight" of "2.0"
    When the "verified_weight" committee is calculated
    Then the committee should have used quorum "from weight"
    And the conclusion of the committee should be "2.0"

  Scenario: Verified package count from nothing
    Given a shipment emitter
    When the "verified_package_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"
  
  Scenario: Verified package count from invalid package count
    Given a shipment emitter
    And a characteristic "package_count" of "0.0"
    When the "verified_package_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"

  Scenario: Verified package count from valid package count
    Given a shipment emitter
    And a characteristic "package_count" of "2"
    When the "verified_package_count" committee is calculated
    Then the committee should have used quorum "from package count"
    And the conclusion of the committee should be "2"

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

  Scenario Outline: Origin location from goecodeable origin
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    When the "origin_location" committee is calculated
    Then the committee should have used quorum "from origin"
    And the conclusion of the committee should be "<location>"
    Examples:
      | origin                                        | location                |
      | 05753                                         | 43.9968185,-73.1491165  |
      | San Francisco, CA                             | 37.7749295,-122.4194155 |
      | Address: 488 Haight Street, San Francisco, CA | 37.7721568,-122.4302295 |
      | Canterbury, Kent, UK                          | 51.2772689,1.0805173    |

  Scenario Outline: Origin location from non-geocodeable origin
    Given a shipment emitter
    And a characteristic "origin" of "<origin>"
    When the "origin_location" committee is calculated
    Then the conclusion of the committee should be nil
    Examples:
      | origin                                                            |
      | 00000                                                             |
      | Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth |

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

  Scenario Outline: Destination location from goecodeable destination
    Given a shipment emitter
    And a characteristic "destination" of "<destination>"
    When the "destination_location" committee is calculated
    Then the committee should have used quorum "from destination"
    And the conclusion of the committee should be "<location>"
    Examples:
      | destination                                    | location                |
      | 05401                                          | 44.4774456,-73.2163467  |
      | San Francisco, CA                              | 37.7749295,-122.4194155 |
      | Address: 488 Haight Street, San Francisco, CA  | 37.7721568,-122.4302295 |
      | Canterbury, Kent, UK                           | 51.2772689,1.0805173    |

  Scenario Outline: Destination location from non-geocodeable destination
    Given a shipment emitter
    And a characteristic "destination" of "<destination>"
    When the "destination_location" committee is calculated
    Then the conclusion of the committee should be nil
    Examples:
      | destination                                                                |
      | 00000                                                                      |
      | Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth |

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

  Scenario Outline: Dogleg factor from segment count
    Given a shipment emitter
    And a characteristic "segment_count" of "<segments>"
    When the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | segments | factor |
      | 1        | 1.0    |
      | 5        | 1.8    |
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
    And the conclusion of the committee should be "0.00076955"

  Scenario Outline: Transport emission factor from mode, verified weight, and adjusted distance
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    And a characteristic "verified_weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode, verified weight, and adjusted distance"
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

  Scenario: Transport emission from verified weight, adjusted distance, and transport emission factor
    Given a shipment emitter
    And a characteristic "verified_weight" of "2.0"
    And a characteristic "adjusted_distance" of "100.0"
    And a characteristic "transport_emission_factor" of "2.0"
    When the "transport_emission" committee is calculated
    Then the committee should have used quorum "from verified weight, adjusted distance, and transport emission factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Corporate emission from verified package count and corporate emission factor
    Given a shipment emitter
    And a characteristic "verified_package_count" of "2"
    And a characteristic "corporate_emission_factor" of "2.0"
    When the "corporate_emission" committee is calculated
    Then the committee should have used quorum "from verified package count and corporate emission factor"
    And the conclusion of the committee should be "4.0"

  Scenario: Emission from transport emission and corporate emission
    Given a shipment emitter
    And a characteristic "transport_emission" of "400.0"
    And a characteristic "corporate_emission" of "20.0"
    When the "emission" committee is calculated
    Then the committee should have used quorum "from transport emission and corporate emission"
    And the conclusion of the committee should be "420.0"
