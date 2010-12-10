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
  
  Scenario: Shipping company from nothing
    Given a shipment emitter
    When the "shipping_company" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should have "name" of "US average"
  
  Scenario: Mode from nothing
    Given a shipment emitter
    When the "mode" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should have "name" of "US average"
  
  Scenario: Segment count from nothing
    Given a shipment emitter
    When the "segment_count" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "5"

  Scenario Outline: Distance from origin zip code, destination zip code, and mode
    Given a shipment emitter
    And a characteristic "origin_zip_code.name" of "<origin>"
    And a characteristic "destination_zip_code.name" of "<destination>"
    And a characteristic "mode.name" of "<mode>"
    When the "distance" committee is calculated
    Then the committee should have used quorum "from origin zip code, destination zip code, and mode"
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | mode            | distance   |
      | 05753  | 05753       | ground courrier | 99999      |
      | 05753  | 05401       | ground courrier | 99999      |
      | 05753  | 20860       | ground courrier | 99999      |
      | 05401  | 05401       | air transport   | 99999      |
      | 05401  | 94128       | air transport   | 4133.31657 |
      | 05401  | 20860       | air transport   | 99999      |
      | 05401  | 05401       | ground carrier  | 99999      |
      | 05401  | 94128       | ground carrier  | 99999      |
      | 05401  | 20860       | ground carrier  | 99999      |
      | 05753  | 05753       | US average      | 99999      |
      | 05753  | 94122       | US average      | 99999      |
      | 05753  | 20860       | US average      | 99999      |

  Scenario Outline: Route inefficiency factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "route_inefficiency_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | mode            | factor |
      | ground courrier | 5.0    |
      | ground carrier  | 1.0    |
      | air transport   | 1.1    |
      | US average      | 2.0    |

  Scenario Outline: Dogleg factor from segment count
    Given a shipment emitter
    And a characteristic "segment_count" of "<segments>"
    When the "dogleg_factor" committee is calculated
    Then the committee should have used quorum "from segment count"
    And the conclusion of the committee should be "<factor>"
    Examples:
      | segments | factor |
      | 0        | error  |
      | 1        | 1.0    |
      | 5        | 5.0625 |

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

  Scenario Outline: Transport emission factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode            | emission_factor |
      | ground courrier | 2.0             |
      | ground carrier  | 1.0             |
      | air transport   | 5.0             |
      | US average      | 3.0             |

  Scenario Outline: Intermodal and corporate emission factor from shipping company
    Given a shipment emitter
    And a characteristic "shipping_company.name" of "<name>"
    When the "intermodal_and_corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from shipping company"
    And the conclusion of the committee should be "<ef>"
    Examples:
      | name       | ef  |
      | FedEx      | 2.0 |
      | US average | 3.0 |

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
      | mode            | weight | adjusted_distance | ef  | emission |
      | ground courrier | 2.0    | 100.0             | 2.0 | 2.0      |
      | ground carrier  | 2.0    | 100.0             | 1.0 | 200.0    |
      | air transport   | 2.0    | 100.0             | 5.0 | 1000.0   |
      | US average      | 2.0    | 100.0             | 3.0 | 600.0    |

  Scenario: Intermodal and corporate emission from package count and intermodal and corporate emission factor
    Given a shipment emitter
    And a characteristic "package_count" of "2"
    And a characteristic "intermodal_and_corporate_emission_factor" of "2.0"
    When the "intermodal_and_corporate_emission" committee is calculated
    Then the committee should have used quorum "from package count and intermodal and corporate emission factor"
    And the conclusion of the committee should be "4.0"

  Scenario: Emission from transport emission and intermodal and corporate emission
    Given a shipment emitter
    And a characteristic "transport_emission" of "400.0"
    And a characteristic "intermodal_and_corporate_emission" of "20.0"
    When the "emission" committee is calculated
    Then the committee should have used quorum "from transport emission and intermodal and corporate emission"
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