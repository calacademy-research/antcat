Feature: Deleting a taxon
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Deleted taxon (with feed)
    # Create Formicidae to make sure the deleted taxon has a parent.
    Given the Formicidae family exists
    And there is a subfamily "Antcatinae"

    When I go to the catalog page for "Antcatinae"
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "Taxon was successfully deleted."

    When I go to the activity feed
    Then I should see "Archibald deleted the subfamily Antcatinae" within the activity feed

  Scenario: If taxon has only references from others taxt, still show the Delete button, but allow deleting
    Given there is a genus "Atta"
    And there is a genus "Eciton"
    And there is a reference section for "Eciton" that includes a tag for "Atta"

    When I go to the catalog page for "Atta"
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "Other records refer to this taxon, so it can't be deleted. "
    And I should not see "Taxon was successfully deleted"
