@javascript
Feature: Deleting a taxon
  As an editor of AntCat
  I want to delete taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And I log in

  Scenario: Deleting a taxon that was just added
    Given there is a genus "Eciton"
    When I go to the catalog page for "Formicinae"
      * I press "Edit"
      * I press "Add genus"
      * I click the name field
      * I set the name to "Atta"
      * I press "OK"
      * I click the protonym name field
      * I set the protonym name to "Eciton"
      * I press "OK"
      * I click the authorship field
      * I search for the author "Fisher"
      * I click the first search result
      * I press "OK"
      * I click the type name field
      * I set the type name to "Atta major"
      * I press "OK"
      * I press "Add this name"
      * I save my changes
    When I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    Then I should be on the catalog page for "Formicinae"
    When I press "Edit"
      * I press "Add genus"
      * I click the name field
      * I set the name to "Atta"
      * I press "OK"
      * I click the protonym name field
      * I set the protonym name to "Eciton"
      * I press "OK"
      * I click the authorship field
      * I search for the author "Fisher"
      * I click the first search result
      * I press "OK"
      * I click the type name field
      * I set the type name to "Atta major"
      * I press "OK"
      * I save my changes
    Then I should be on the catalog page for "Atta"
      And I should see "Eciton" in the protonym
    When I go to the catalog page for "Formicinae"
      Then I should see "Atta" in the index

  Scenario: Can't delete if taxon has stuff hanging off of it
