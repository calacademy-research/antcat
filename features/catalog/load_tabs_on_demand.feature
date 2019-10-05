Feature: Load taxon browser tabs on demand
  Background:
    Given the maximum number of taxa to load in each tab is 2
    And the Formicidae family exists
    And there is a subfamily "Aninae"
    And there is a subfamily "Baninae"

  Scenario: Under the maximum number
    When I go to the catalog
    Then I should see "Aninae" within the taxon browser
    And I should see "Baninae" within the taxon browser
    And I should not see "Load all?"

  @javascript
  Scenario: Over the maximum number
    Given there is a subfamily "Caninae"

    When I go to the catalog
    Then I should see "Aninae" within the taxon browser
    And I should see "Baninae" within the taxon browser
    And I should not see "Caninae" within the taxon browser
    And I should see "Showing 2 of 3 taxa"

    When I follow "Load all?"
    Then I should see "Caninae" within the taxon browser
    And I should not see "Load all?"
