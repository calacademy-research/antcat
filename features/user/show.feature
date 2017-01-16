Feature: User page
  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: Visiting a user's page
    When I go to the users page
    Then I should see a link to the user page for "Batiatus"

    When I follow "Batiatus" in the users list
    Then I should be on the user page for "Batiatus"
    And there should be a mailto link to the email of "Batiatus"
    And I should see "Name: Batiatus"
    And I should see "Batiatus's most recent activity"
    And I should see "No activities"
    And I should see "Batiatus's most recent comments"
    And I should see "No comments"

  @feed
  Scenario: See user's most recent feed activities
    Given I add a journal for the feed

    When I go to the user page for "Batiatus"
    Then I should see "Batiatus's most recent activity"
    And I should see "Batiatus added the journal Archibald Bulletin"

  Scenario: See user's most recent comments
    Given Batiatus has commented "Cool" on an issue with the title "Typos"

    When I go to the user page for "Batiatus"
    Then I should see "Batiatus's most recent comments"
    And I should see "Batiatus commented on the issue Typos:"
