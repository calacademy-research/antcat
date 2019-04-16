Feature: Changes
  Background:
    Given I log in as a catalog editor named "Mark Wilden"

  @javascript
  Scenario: Adding a taxon and seeing it on the Changes page
    Given this reference exist
      | author | citation_year |
      | Fisher | 2004          |
    And the default reference is "Fisher, 2004"
    And there is a subfamily "Formicinae"

    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I click the name field
    And I set the name to "Atta"
    And I press "OK"
    And I click the protonym name field
    And I press "OK"
    And WAIT_FOR_JQUERY
    And I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "page 35"
    And I press "Save"
    Then I should see "This taxon has been changed; changes awaiting approval"

    When I go to the changes page
    Then I should see "added Atta"

  Scenario: Approving a change
    Given there is a genus "Atta" that's waiting for approval

    When I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden"

    When I log in as a catalog editor named "Stan Blum"
    And I go to the changes page
    And I follow "Approve"
    Then I should not see "Approve[^d]"
    And I should see "Stan Blum approved"

    When I go to the catalog page for "Atta"
    Then I should see "approved by Stan Blum"

  Scenario: Approving all changes
    Given there is a genus "Atta" that's waiting for approval

    When I log in as a superadmin
    And I go to the unreviewed changes page
    Then I should see "Approve all"

    Given I will confirm on the next step
    When I follow "Approve all"
    And I go to the unreviewed changes page
    Then I should not see "Approve[^d]"
    And I should see "There are no unreviewed changes."

  @papertrail
  Scenario: Another editor editing a change that's waiting for approval
    Given there is a genus "Atta" that's waiting for approval

    When I go to the changes page
    Then I should see "Mark Wilden added"

    When I log in as a catalog editor named "Stan Blum"
    And I go to the changes page
    And I follow "Atta"
    And I follow "Edit"
    And I select "genus" from "taxon_incertae_sedis_in"
    And I save the taxon form
    And I follow "Review change"
    Then I should see "Stan Blum changed"

    When I log in as a catalog editor named "Mark Wilden"
    And I go to the changes page
    And I follow "Approve"
    Then I should see "Mark Wilden approved"

    When I go to the catalog page for "Atta"
    Then I should see "approved by Mark Wilden"

  @papertrail
  Scenario: Editing a taxon - modified, not added
    Given there is a genus "Eciton"

    When I go to the catalog page for "Eciton"
    # We want this next step after tweaking the factories.
    # Then I should not see "This taxon has been changed"
    And I should not see "Changed by Mark Wilden"

    When I go to the edit page for "Eciton"
    And I select "genus" from "taxon_incertae_sedis_in"
    And I save the taxon form
    Then I should see "This taxon has been changed"
    And I should see "Changed by Mark Wilden"

    When I go to the changes page
    Then I should see "Mark Wilden changed Eciton"
