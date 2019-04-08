Feature: User page
  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: Visiting a user's page
    Given this user exists
      | email              | name    |
      | quintus@antcat.org | Quintus |

    When I go to the users page
    And I follow "Quintus"
    Then I should see "Name: Quintus"
    And I should see "Email: quintus@antcat.org"
    And I should see "Quintus's most recent activity"
    And I should see "No activities"
    And I should see "Quintus's most recent comments"
    And I should see "No comments"

  @feed
  Scenario: See user's most recent feed activities
    Given there is a "destroy" journal activity

    When I go to the user page for "Batiatus"
    Then I should see "Batiatus's most recent activity"
    And I should see "Batiatus deleted the journal"

  Scenario: See user's most recent comments
    Given Batiatus has commented "Cool" on an issue with the title "Typos"

    When I go to the user page for "Batiatus"
    Then I should see "Batiatus's most recent comments"
    And I should see "Batiatus commented on the issue Typos:"
