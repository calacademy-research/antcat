Feature: Using the catalog
  Background:
    Given the Formicidae family exists
    And there is a subfamily "Dolichoderinae"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini"
    And there is a species "Dolichoderus abruptus" with genus "Dolichoderus"
    And there is a subspecies "Dolichoderus abruptus minor" which is a subspecies of "Dolichoderus abruptus"
    And I go to the catalog

  Scenario: Going to the main page
    Then I should see "Formicidae"
    And I should see "Subfamily of Formicidae: Dolichoderinae"

  Scenario: Selecting a subfamily
    When I follow "Dolichoderinae" in the taxon browser
    Then "Dolichoderinae" should be selected

  Scenario: Selecting a tribe
    When I follow "Dolichoderinae" in the taxon browser
    And I follow "Dolichoderini" in the taxon browser
    Then "Dolichoderinae" should be selected
    And "Dolichoderini" should be selected
    And I should see "Dolichoderus" in the taxon browser

  Scenario: Selecting a genus
    When I follow "Dolichoderinae" in the taxon browser
    And I follow "All genera" in the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderus" should be selected
    And I should see "abruptus" in the taxon browser

  Scenario: Selecting a species
    When I follow "Dolichoderinae" in the taxon browser
    And I follow "All genera" in the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    And I follow "abruptus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderus" should be selected
    And "abruptus" should be selected

  Scenario: Selecting a subspecies
    When I follow "Dolichoderinae" in the taxon browser
    And I follow "All genera" in the subfamilies taxon browser tab
    And I follow "Dolichoderus"
    Then I should see "abruptus" in the taxon browser

    When I follow "abruptus"
    Then I should see "minor" in the taxon browser
