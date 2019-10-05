Feature: Using the catalog
  Background:
    Given the Formicidae family exists
    And there is a subfamily "Dolichoderinae"
    And there is a tribe "Dolichoderini" in the subfamily "Dolichoderinae"
    And there is a genus "Dolichoderus" in the tribe "Dolichoderini"
    And there is a species "Dolichoderus abruptus" in the genus "Dolichoderus"
    And there is a subspecies "Dolichoderus abruptus minor" in the species "Dolichoderus abruptus"
    And I go to the catalog

  Scenario: Going to the main page
    Then I should see "Formicidae"
    And I should see "Subfamilies of Formicidae: Dolichoderinae"

  Scenario: Selecting a subfamily
    When I follow "Dolichoderinae" within the taxon browser
    Then "Dolichoderinae" should be selected in the taxon browser

  Scenario: Selecting a tribe
    When I follow "Dolichoderinae" within the taxon browser
    And I follow "Dolichoderini" within the taxon browser
    Then "Dolichoderinae" should be selected in the taxon browser
    And "Dolichoderini" should be selected in the taxon browser
    And I should see "Dolichoderus" within the taxon browser

  Scenario: Selecting a genus
    When I follow "Dolichoderinae" within the taxon browser
    And I follow "All genera" within the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected in the taxon browser
    And "Dolichoderus" should be selected in the taxon browser
    And I should see "abruptus" within the taxon browser

  Scenario: Selecting a species
    When I follow "Dolichoderinae" within the taxon browser
    And I follow "All genera" within the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    And I follow "abruptus"
    Then "Dolichoderinae" should be selected in the taxon browser
    And "Dolichoderus" should be selected in the taxon browser
    And "abruptus" should be selected in the taxon browser

  Scenario: Selecting a subspecies
    When I follow "Dolichoderinae" within the taxon browser
    And I follow "All genera" within the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    Then I should see "abruptus" within the taxon browser

    When I follow "abruptus"
    Then I should see "minor" within the taxon browser
