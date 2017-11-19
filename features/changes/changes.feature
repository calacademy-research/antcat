# We don't have to use `@papertrail` when we create (cheat) versions in steps.

Feature: Changes
  Background:
    Given I log in as a catalog editor named "Mark Wilden"

  @javascript @search @papertrail
  Scenario: Adding a taxon and seeing it on the Changes page
    Given this reference exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And there is a genus "Eciton"

    When I go to the edit page for "Formicinae"
    And I follow "Add genus"
    And I click the name field
    And I set the name to "Atta"
    And I press "OK"
    And I click the protonym name field
    And I set the protonym name to "Eciton"
    And I press "OK"
    And I click the authorship field
    And in the reference picker, I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    And I click the type name field
    And I set the type name to "Atta major"
    And I press "OK"
    And I press "Add this name"
    And I save my changes
    Then I should see "This taxon has been changed; changes awaiting approval"

    When I follow "Review change"
    Then I should see "Atta"

    When I follow "Atta"
    Then I should be on the catalog page for "Atta"

  Scenario: Approving a change
    Given I add the genus "Atta"

    When I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden"

    When I log in as a catalog editor named "Stan Blum"
    And I go to the changes page
    And I will confirm on the next step
    And I follow "Approve"
    Then I should not see "Approve[^d]"
    And I should see "Stan Blum approved"

    When I go to the catalog page for "Atta"
    Then I should see "approved by Stan Blum"

  Scenario: Approving all changes
    Given I add the genus "Atta"
    And I add the genus "Batta"

    When I log in as a superadmin named "Stan Blum"
    And I go to the unreviewed changes page
    Then I should see "Approve all"

    Given I will confirm on the next step
    When I follow "Approve all"
    And I go to the unreviewed changes page
    Then I should not see "Approve[^d]"

  Scenario: Should not see approve all if not superadmin
    Given I add the genus "Atta"

    When I go to the unreviewed changes page
    Then I should not see "Approve all"
    And I should not see "There are no unreviewed changes."

  @papertrail
  Scenario: Another editor editing a change that's waiting for approval
    When I add the genus "Atta"
    And I go to the changes page
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
    Given I will confirm on the next step
    And I follow "Approve"
    Then I should see "Mark Wilden approved"

    When I go to the catalog page for "Atta"
    Then I should see "approved by Mark Wilden"

  Scenario: Trying to approve one's own change
    When I add the genus "Atta"
    And I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden"

    When I go to the changes page
    Then I should not see "Approve[^?]"

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
