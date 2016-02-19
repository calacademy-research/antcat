Feature: Using the catalog
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
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Dolichoderus"
    Then I should not see "Subdolichoderus"

  Scenario: Showing subgenera
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Dolichoderus"
    And I follow "show subgenera"
    Then I should see "Subdolichoderus"

  Scenario: Selecting a subgenus
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Dolichoderus"
    And I follow "show subgenera"
    And I follow "Subdolichoderus"
    Then I should see "Dolichoderus (Subdolichoderus) history"
    And I should see "abruptus" in the species index

  Scenario: Hiding subgenera after selecting a subgenus
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Dolichoderus"
    And I follow "show subgenera"
    And I follow "Subdolichoderus"
    And I follow "hide subgenera"
    Then I should not see the subgenera index
    And "Dolichoderus" should be selected
