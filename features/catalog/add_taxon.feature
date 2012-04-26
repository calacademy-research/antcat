@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given the Formicidae family exists
    And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"

  Scenario: Adding a genus
    When I go to the catalog
    And I follow "add" in the genera index
    And I set the genus name to "Atta"
    And I save my changes
    Then I should see "Atta" in the genera index

  Scenario: Trying to add a genus with a blank name
    When I go to the catalog
    And I follow "add" in the genera index
    And I set the genus name to ""
    And I save my changes
    Then I should see "Name can't be blank"
