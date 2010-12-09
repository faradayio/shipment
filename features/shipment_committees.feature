Feature: Shipment Committee Calculations
  The shipment model should generate correct committee calculations

  Scenario: Stuff I am assuming Yaktrak takes care of
    Yaktrak uses a "tracking_code" to fetch data from FedEx
    This data includes "weight", "shipping_company.name", and a series of events
    Each event includes a "zip_code"
    Yaktrak groups the events into consecutive pairs
    For each pair of events, Yaktrak determines whether any travel took place between the events
    If travel did occur Yaktrak determines the "mode.name" for that travel i.e. ground pickup (from a customer location to a fedex location), ground delivery (from a fedex location to a customer location), ground transport (between two fedex locations), air transport (between two fedex locations) - I am assuming that all air is between fedex locations and that all ground travel between fedex locations is point-to-point rather than along a route
    For each pair of events where travel occurred Yaktrak sends "weight", "shipping_company.name", "origin_zip_code", "destination_zip_code", and "mode.name" to the shipment emitter
  
  Scenario: Date and timeframe stuff
    Figure out how to determine what portion of the total shipment emissions occurred during a timeframe
    Decide whether we want distance or intermediate emissions to depend on timeframe
  
  Scenario: Mode from nothing
    Given a shipment emitter
    When the "mode" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should have "name" of "US average"
  
  Scenario: Shipping company from nothing
    Given a shipment emitter
    When the "shipping_company" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should have "name" of "US average"
  
  Scenario: Distance from nothing
    Given a shipment emitter
    When the "distance" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "FIXME"
  
  Scenario Outline: Distance from origin zip code, destination zip code, and mode
    Given a shipment emitter
    And a characteristic "origin_zip_code.name" of "<origin>"
    And a characteristic "destination_zip_code.name" of "<destination>"
    And a characteristic "mode.name" of "<mode>"
    When the "distance" committee is calculated
    Then the committee should have used quorum 'from origin zip code, destination zip code, and mode'
    And the conclusion of the committee should be "<distance>"
    Examples:
      | origin | destination | mode             | distance |
      | 05753  | 05753       | ground pickup    | FIXME    |
      | 05753  | 05401       | ground pickup    | FIXME    |
      | 05401  | 05401       | air transport    | FIXME    |
      | 05401  | 94128       | air transport    | FIXME    |
      | 05401  | 05401       | ground transport | FIXME    |
      | 05401  | 94128       | ground transport | FIXME    |
      | 94128  | 94128       | ground delivery  | FIXME    |
      | 94122  | 94122       | ground delivery  | FIXME    |
      | 20860  | 05753       | ground pickup    | FIXME    |
      | 20860  | 05753       | ground transport | FIXME    |
      | 20860  | 05753       | air transport    | FIXME    |
      | 20860  | 05753       | ground delivery  | FIXME    |
      | 05753  | 05753       | US average       | FIXME    |
      | 05753  | 05401       | US average       | FIXME    |
      | 20860  | 05753       | US average       | FIXME    |

  Scenario Outline: Transport emission factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "transport_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode             | emission_factor |
      | ground pickup    | 2.0             |
      | ground delivery  | 2.0             |
      | ground transport | 1.0             |
      | air transport    | 5.0             |
      | US average       | 3.0             |

  Scenario Outline: Intermodal emission factor from mode
    Given a shipment emitter
    And a characteristic "mode.name" of "<mode>"
    When the "intermodal_emission_factor" committee is calculated
    Then the committee should have used quorum "from mode"
    And the conclusion of the committee should be "<emission_factor>"
    Examples:
      | mode             | emission_factor |
      | ground pickup    | 0.0             |
      | ground delivery  | 0.0             |
      | ground transport | 10.0            |
      | air transport    | 20.0            |
      | US average       | 8.0             |

  Scenario Outline: Corporate emission factor from shipping company
    Given a shipment emitter
    And a characteristic "shipping_company.name" of "<name>"
    When the "corporate_emission_factor" committee is calculated
    Then the committee should have used quorum "from shipping company"
    And the conclusion of the committee should be "<ef>"
    Examples:
      | name            | ef  |
      | Federal Express | 2.0 |
      | US average      | 3.0 |

  Scenario: Transport emission from weight, distance, and transport emission factor
    Given a shipment emitter
    And a characteristic "weight" of "2.0"
    And a characteristic "distance" of "100.0"
    And a characteristic "transport_emission_factor" of "2.0"
    When the "transport_emission" committee is calculated
    Then the committee should have used quorum "from weight, distance, and transport emission factor"
    And the conclusion of the committee should be "400.0"

  Scenario: Intermodal emission from weight and intermodal emission factor
    Given a shipment emitter
    And a characteristic "weight" of "2.0"
    And a characteristic "intermodal_emission_factor" of "10.0"
    When the "intermodal_emission" committee is calculated
    Then the committee should have used quorum "from weight and intermodal emission factor"
    And the conclusion of the committee should be "20.0"

  Scenario: Corporate emission from package count and corporate emission factor
    Given a shipment emitter
    And a characteristic "package_count" of "2"
    And a characteristic "corporate_emission_factor" of "2.0"
    When the "corporate_emission" committee is calculated
    Then the committee should have used quorum "from package count and corporate emission factor"
    And the conclusion of the committee should be "4.0"

  Scenario: Emission from transport emission, intermodal emission, and corporate emission
    Given a shipment emitter
    And a characteristic "transport_emission" of "400.0"
    And a characteristic "intermodal_emission" of "20.0"
    And a characteristic "corporate_emission" of "4.0"
    When the "emission" committee is calculated
    Then the committee should have used quorum "from transport emission, intermodal emission, and corporate emission"
    And the conclusion of the committee should be "424.0"

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