Feature: Deleting a taxon
  As an editor of AntCat
  I want to delete taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given the Formicidae family exists
    Given a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"
    And I log in

  Scenario: Deleting a taxon that was just added
    When I go to the catalog page for "Atta"
    When I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    Then I should be on the catalog page for "Dolichoderinae"
    And I should see "Taxon was successfully deleted"

  Scenario: Can delete even if taxon is referred to by child records
    When I go to the catalog page for "Atta"
    Given I add a history item to "Dolichoderinae"
    When I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    And I should be on the catalog page for "Dolichoderinae"
    And I should see "Taxon was successfully deleted"

  Scenario: If taxon has only references from others taxt, still show the Delete button, but don't let them delete
    Given there is a genus "Eciton"
    And I add a history item to "Eciton" that includes a tag for "Atta"
    When I go to the catalog page for "Atta"
    And I press "Edit"
    And I will confirm on the next step
    And I press "Delete"
    Then I should see "Other taxa refer to this taxon, so it can't be deleted. "
    And I should not see "Taxon was successfully deleted"
