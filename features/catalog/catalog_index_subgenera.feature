Feature: Using the catalog index
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background: 
    Given the Formicidae family exists
    And subfamily "Dolichoderinae" exists
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And subgenus "Dolichoderus (Subdolichoderus)" exists in that genus
    And species "Dolichoderus (Subdolichoderus) abruptus" exists in that subgenus
    And subspecies "Dolichoderus (Subdolichoderus) abruptus minor" exists in that species

  Scenario: Subgenera are initially hidden
    When I go to the catalog index
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    Then I should not see "Subdolichoderus"

  Scenario: Selecting a subgenus
    When I go to the catalog index
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    And I follow "Subdolichoderus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderini" should be selected
    And "Dolichoderus" should be selected
    And "Subdolichoderus" should be selected
    And I should see "Dolichoderus (Subdolichoderus) history"
    And I should see "1 valid species, 1 valid subspecies"
    And I should see "abruptus" in the index
    And I should see "minor" in the index
