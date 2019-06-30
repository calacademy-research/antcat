Feature: Editor's Panel
  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: See most recent feed activities
    Given there is a "destroy" journal activity

    When I go to the Editor's Panel
    Then I should see "Most recent activity"
    And I should see "Batiatus deleted the journal"

  Scenario: See most recent comments
    Given Batiatus has commented "Cool" on an issue with the title "Typos"

    When I go to the Editor's Panel
    Then I should see "Most recent comments"
    And I should see "Batiatus commented on the issue Typos:"

  Scenario: See number of unreviewed changes
    Given a visitor has submitted a feedback
    And Batiatus has commented "Cool" on an issue with the title "Typos"

    When I go to the Editor's Panel
    Then I should see "1 Open issues"
    And I should see "0 Unreviewed references"
    And I should see "1 Pending feedbacks"
