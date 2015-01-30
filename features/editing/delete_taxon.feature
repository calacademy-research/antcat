@javascript
@allow_rescue
Feature: Deleting a taxon
  As an editor of AntCat
  I want to delete taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given the Formicidae family exists
    And that version tracking is enabled
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
      * there is a subfamily "Dolichoderinae"
      * I log in
      * there is a genus "Eciton"
      * I go to the catalog page for "Dolichoderinae"
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
      * the changes are approved
      * I go to the catalog page for "Atta"

  Scenario: Deleting a taxon that was just added
    When I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    And I will confirm on the next step
    Then I should be on the catalog page for "Dolichoderinae"
    And I should see "Dolichoderinae" in the header

  Scenario: Can delete even if taxon is referred to by child records
    Given I add a history item to "Dolichoderinae"
    When I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    And I will confirm on the next step
    Then I should not see "This taxon already has additional information attached to it."
    And I should be on the catalog page for "Dolichoderinae"
    And I should see "Dolichoderinae" in the header

  Scenario: If taxon has only references from others taxt, still show the Delete button, but don't let them delete
    Given there is a genus "Formica"
    And there is a genus "Eciton"
    And I add a history item to "Eciton" that includes a tag for "Formica"
    When I go to the catalog page for "Formica"
    And I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    And I will confirm on the next step
    Then I should see "Other taxa refer to this taxon, so it can't be deleted. "
