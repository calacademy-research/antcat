Feature: Showing/hiding invalid taxa
  As a user of AntCat
  I want choose whether or not to take up screen space with invalid taxa
  So I can see more useful information

  Background:
    Given the Formicidae family exists
    And there is a subfamily "Availableinae"
    And there is an invalid subfamily Invalidinae

  Scenario: Invalid taxa are initially hidden
    When I go to the catalog
    Then I should see "Availableinae"
    And I should not see "Invalidinae"

  Scenario: Showing invalid taxa
    When I go to the catalog
    And I follow "show invalid"
    Then I should see "Invalidinae"
    And I should see "Availableinae"

    When I follow "show valid only"
    Then I should see "Availableinae"
    And I should not see "Invalidinae"
