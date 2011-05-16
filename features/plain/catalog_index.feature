Feature: Using the catalog index
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
    And a species exists with a name of "abruptus" and a genus of "Dolichoderus" and a taxonomic history of "abruptus history"

  Scenario: Before selecting anything
    When I go to the catalog index
    Then I should see "Dolichoderinae" in the index
      And I should not see "Dolichoderinae history"

  Scenario: Selecting a subfamily
    When I go to the catalog index
      And I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
      And I should see "Dolichoderinae history"
      And I should see "Dolichoderini" in the index
      #And I should see "2 valid genera (1 synonym)"

  Scenario: Selecting a tribe
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And I should see "Dolichoderini history"
      #And I should see "2 valid genera (1 synonym)"
      And I should see "Dolichoderus" in the index

  Scenario: Selecting a genus
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And "Dolichoderus" should be selected
      And I should see "Dolichoderus history"
      #And I should see "2 valid genera (1 synonym)"
      And I should see "abruptus" in the index

  Scenario: Selecting a species
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "Dolichoderus"
      And I follow "abruptus"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And "Dolichoderus" should be selected
      And "abruptus" should be selected
      And I should see "abruptus history"

  Scenario: Showing the "incertae sedis" subfamily
    Given a genus exists with a name of "Cariridris" and no subfamily
    When I go to the catalog index
      And I follow "(incertae sedis)"
    Then I should see "Cariridris"
      And "(incertae sedis)" should be selected
      And I should not see "Tribes"
      And I should not see "show tribes"

  Scenario: Showing the "incertae sedis" tribe
    Given a genus exists with a name of "Cariridris" and a subfamily of "Dolichoderinae"
      And a genus exists with a name of "Atta" and a subfamily of "Attaninae"
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "(incertae sedis)" in the tribes index
    Then I should see "Cariridris" in the genera index
      And I should not see "Atta" in the genera index
      And "(incertae sedis)" should be selected in the tribes index
      And "Dolichoderinae" should be selected in the subfamilies index

