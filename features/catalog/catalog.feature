Feature: Using the catalog
  Background:
    Given the Formicidae family exists
    And there is a subfamily "Dolichoderinae"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini"
    And a genus exists with a name of "Atta" and no subfamily
    And a fossil genus exists with a name of "Brownerus" and a tribe of "Dolichoderini"
    And a species exists with a name of "abruptus" and a genus of "Dolichoderus"
    And a subspecies exists for that species with a name of "Dolichoderus abruptus minor" and an epithet of "minor"
    And a genus exists with a name of "Camponotus" and a subfamily of "Dolichoderinae"
    And a species exists with a name of "abruptus" and a genus of "Camponotus"

  Scenario: Going to the root
    When I go to the catalog
    Then I should see "Formicidae" in the taxon description
    And I should see "Extant: 1 valid subfamily, 1 valid tribe, 3 valid genera, 2 valid species, 1 valid subspecies"
    And I should see "Fossil: 1 valid genus"
    And I should see "Subfamily of Formicidae: Dolichoderinae."

  Scenario: Seeing the family when it's been explicitly requested
    When I go to the catalog page for "Formicidae"
    Then I should see "Formicidae" in the taxon description
    And I should see "valid" in the taxon description
    And I should see "Extant: 1 valid subfamily, 1 valid tribe, 3 valid genera, 2 valid species, 1 valid subspecies"
    And I should see "Fossil: 1 valid genus"
    And I should see "Subfamily of Formicidae: Dolichoderinae."
    And the page title should have "Formicidae" in it

  Scenario: Selecting a subfamily
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    Then "Dolichoderinae" should be selected
    And I should see "Extant: 1 valid tribe, 2 valid genera, 2 valid species, 1 valid subspecies"
    And I should see "Fossil: 1 valid genus"

  Scenario: Selecting a tribe
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Dolichoderini" in the index
    Then "Dolichoderinae" should be selected
    And I should see "Dolichoderini" in the taxon description
    And "Dolichoderini" should be selected
    And I should see "Dolichoderus" in the index

  Scenario: Selecting a genus
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "All genera" in the subfamilies index
    And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderus" should be selected
    And I should see "1 valid species, 1 valid subspecies"
    And I should see "abruptus" in the index

  Scenario: Selecting a species
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "All genera" in the subfamilies index
    And I follow "Dolichoderus"
    And I follow "abruptus"
    Then "Dolichoderinae" should be selected
    And "Dolichoderus" should be selected
    And "abruptus" should be selected

  Scenario: Selecting a subspecies from the species list
    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "All genera" in the subfamilies index
    And I follow "Dolichoderus"
    Then I should see "abruptus" in the index

    When I follow "abruptus"
    Then I should see "minor" in the index

  Scenario: Showing the "no tribe" tribe
    Given PENDING
    Given a genus exists with a name of "Cariridris" and a subfamily of "Dolichoderinae"

    When I go to the catalog
    And I follow "Dolichoderinae" in the index
    And I follow "Incertae sedis" in the subfamilies index
    Then I should see "Cariridris" in the genera index
    And I should not see "Atta" in the genera index
    And "Incertae sedis" should be selected in the subfamilies index
    And "Dolichoderinae" should be selected in the families index

  Scenario: Displaying items containing broken taxt links
    Given I am logged in
    And there is a genus "Atta"
    And Atta has a history section item with two linked references, of which one does not exists

    When I go to the catalog page for "Atta"
    Then I should see "Batiatus, 2000"
    And I should see "CANNOT FIND REFERENCE WITH ID 99999"

    When I follow "Search history?"
    Then the "item_id" field should contain "99999"
