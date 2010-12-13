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
  
  Scenario: Carrier from nothing
    Given a shipment emitter
    When the "carrier" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be a fallback
  
  Scenario: Mode from nothing
    Given a shipment emitter
    When the "mode" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be a fallback
  
  Scenario Outline: Distance from origin zip code and destination zip code
    Given a shipment emitter
    And a characteristic "origin_zip_code.name" of "<origin>"
    And a characteristic "destination_zip_code.name" of "<destination>"
    When the "distance" committee is calculated
    Then the committee should have used quorum "from origin zip code and destination zip code"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | distance |
      | 05753  | 05753       | 0        |
      | 05753  | 05401       | 53       |

  Scenario Outline: Distance from zip codes not in database or missing lat/lng
    Given a shipment emitter
    And a characteristic "origin_zip_code.name" of "<origin>"
    And a characteristic "destination_zip_code.name" of "<destination>"
    When the "distance" committee is calculated
    Then the conclusion of the committee should be nil
    Examples:
      | origin | destination |
      | 05753  | 20860       |
      | 05753  | 99999       |

  Scenario: Route inefficiency factor from nothing
    Given a shipment emitter
    When the "mode" committee is calculated
    And the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "from mode"
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

  Scenario: Dogleg factor from nothing
    Given a shipment emitter
    When the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "1.8"

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
      | 100      | 1.8    |
      | -20      | 1.8    |

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

  Scenario: Transport emission factor from default mode
    Given a shipment emitter
    When the "mode" committee is calculated
    And the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "0.00076955"

  Scenario Outline: Transport emission factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode    | emission_factor |
      | courier | 2.0             |
      | ground  | 1.0             |
      | air     | 5.0             |

  Scenario: Corporate emission factor from default carrier
    Given a shipment emitter
    When the "carrier" committee is calculated
    And the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "0.318"

  Scenario: Corporate emission factor from carrier
    Given a shipment emitter
    And a characteristic "carrier.name" of "FedEx"
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from carrier"
    And the conclusion of the committee should be "2.0"

  Scenario: Transport emission from defaults
    Given a shipment emitter
    When the "weight" committee is calculated
    And the "mode" committee is calculated
    And the "adjusted_distance" committee is calculated
    And the "transport_emission_factor" committee is calculated
    And the "transport_emission" committee is calculated
    Then the committee should have used quorum "from mode, weight, adjusted distance, and transport emission factor"
    And the conclusion of the committee should be "8.42296"

  Scenario Outline: Transport emission from mode, weight, adjusted distance, and transport emission factor
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    And a characteristic "weight" of "<weight>"
    And a characteristic "adjusted_distance" of "<adjusted_distance>"
    And a characteristic "transport_emission_factor" of "<ef>"
    When the "transport_emission" committee is calculated
    Then the committee should have used quorum "from mode, weight, adjusted distance, and transport emission factor"
    And the conclusion of the committee should be "<emission>"
    Examples:
      | mode    | weight | adjusted_distance | ef  | emission |
      | courier | 2.0    | 100.0             | 2.0 | 2.0      |
      | ground  | 2.0    | 100.0             | 1.0 | 200.0    |
      | air     | 2.0    | 100.0             | 5.0 | 1000.0   |

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

  # Scenario Outline: Duration from timestamps
  #   Given a shipment emitter
  #   And a characteristic "origin_timestamp" of "<origin>"
  #   And a characteristic "destination_timestamp" of "<destination>"
  #   When the "duration" committee is calculated
  #   Then the committee should have used quorum "from timestamps"
  #   And the conclusion of the committee should be "<duration>"
  #   Examples:
  #     | origin                    | destination               | duration |
  #     | 2010-01-01T00:00:00Z      | 2010-01-02T01:30:00Z      | 01:30:00 | same timezone
  #     | 2010-01-01T00:00:00Z      | 2010-01-02T09:30:00+08:00 | 01:30:00 | different timezones
  #     | 2010-01-01T00:00:00Z      | 2009-12-31T20:30:00-05:00 | 01:30:00 | timezone change causes different days
  #     | 2010-01-01T12:00:00+12:00 | 2009-12-31T13:30:00-12:00 | 01:30:00 | cross intl date line eastwards
  #     | 2010-01-01T12:00:00-12:00 | 2009-01-02T13:30:00+12:00 | 01:30:00 | cross intl date line westwards
