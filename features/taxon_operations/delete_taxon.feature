Feature: Deleting a taxon
  Background:
    Given I am logged in

  Scenario: Deleting a taxon that was just added
    Given a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"

    When I go to the catalog page for "Atta"
    And I will confirm on the next step
    And I follow "Delete"
    Then I should be on the catalog page for "Dolichoderinae"
    And I should see "Taxon was successfully deleted"

  Scenario: Can delete even if taxon is referred to by child records
    Given a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"
    And I add a history item to "Dolichoderinae"

    When I go to the catalog page for "Atta"
    And I will confirm on the next step
    And I follow "Delete"
    Then I should be on the catalog page for "Dolichoderinae"
    And I should see "Taxon was successfully deleted"

  Scenario: If taxon has only references from others taxt, still show the Delete button, but don't let them delete
    Given there is a genus "Atta"
    And there is a genus "Eciton"
    And I add a history item to "Eciton" that includes a tag for "Atta"

    When I go to the catalog page for "Atta"
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "Other taxa refer to this taxon, so it can't be deleted. "
    And I should not see "Taxon was successfully deleted"
