Feature: Using the catalog
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background: 
    Given the Formicidae family exists
    And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
    And a genus exists with a name of "Atta" and no subfamily and a taxonomic history of "Atta history"
    And a fossil genus exists with a name of "Brownerus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
    And a species exists with a name of "abruptus" and a genus of "Dolichoderus" and a taxonomic history of "abruptus history"
    And a subspecies exists for that species with a name of "Dolichoderus abruptus minor" and an epithet of "minor" and a taxonomic history of "minor history"
    And a genus exists with a name of "Camponotus" and a subfamily of "Dolichoderinae" and a taxonomic history of "Campononotus history"
    And a species exists with a name of "abruptus" and a genus of "Camponotus" and a taxonomic history of "abruptus history"

  Scenario: Seeing the family
    When I go to the catalog
    Then I should see "Formicidae" in the contents
    And I should see "valid" in the contents
    And I should see "Extant: 1 valid subfamily, 1 valid tribe, 3 valid genera, 2 valid species, 1 valid subspecies"
    And I should see "Fossil: 1 valid genus"
    And I should see "Subfamily of Formicidae: Dolichoderinae."

  Scenario: Seeing the subfamilies
    When I go to the catalog
    Then I should see "Dolichoderinae" in the index
    And I should not see "Dolichoderinae history"
    And I should not see "Atta" in the index

  Scenario: Choosing '(no subfamily)'
    When I go to the catalog
    And I follow "(no subfamily)"
    Then I should see "Atta" in the index

  Scenario: Selecting a genus without a subfamily
    When I go to the catalog
    * I follow "(no subfamily)"
    * I follow "Atta"
    Then "(no subfamily)" should be selected
    And "Atta" should be selected
    And I should see "Atta history"

  Scenario: Selecting a subfamily
    When I go to the catalog
    And I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
    And I should see "Dolichoderini" in the contents
    And I should see "Dolichoderinae history"
    And I should see "Extant: 1 valid tribe, 2 valid genera, 2 valid species, 1 valid subspecies"
    And I should see "Fossil: 1 valid genus"
    And I should see "Dolichoderini" in the index

  Scenario: Selecting a tribe
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    Then "Dolichoderinae" should be selected
    And I should see "Dolichoderini" in the contents
    And "Dolichoderini" should be selected
    And I should see "Dolichoderini history"
    And I should see "Dolichoderus" in the index

  Scenario: Selecting a genus
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderini" should be selected
    And "Dolichoderus" should be selected
    And I should see "Dolichoderus history"
    And I should see "1 valid species, 1 valid subspecies"
    And I should see "abruptus" in the index
    And I should see "minor" in the index

  Scenario: Selecting a species
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    And I follow "abruptus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderini" should be selected
    And "Dolichoderus" should be selected
    And "abruptus" should be selected
    And I should see "abruptus history"

  Scenario: Selecting a subspecies from the species list
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    Then I should see "abruptus" in the index
    And I should see "minor" in the index
    When I follow "minor"
    Then I should see "minor history"
    And I should see "abruptus" in the index
    And I should see "minor" in the index

  Scenario: Showing the "no tribe" tribe
    Given a genus exists with a name of "Cariridris" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Atta" and a subfamily of "Attaninae"
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "(no tribe)" in the tribes index
    Then I should see "Cariridris" in the genera index
    And I should not see "Atta" in the genera index
    And "(no tribe)" should be selected in the tribes index
    And "Dolichoderinae" should be selected in the subfamilies index
    And I should see "Dolichoderinae history"

  Scenario: Showing the "no subfamily" subfamily
    Given a genus exists with a name of "Cariridris" and no subfamily
    When I go to the catalog
    And I follow "show tribes"
    And I follow "(no subfamily)"
    Then I should see "Cariridris"
    And "(no subfamily)" should be selected
    And I should not see "Tribes"

