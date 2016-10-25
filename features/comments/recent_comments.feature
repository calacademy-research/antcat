Feature: Browse recent comments
  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: No comments yet
    When I go to the comments page
    Then I should see "No comments."

  Scenario: Browsing comments by date
    Given Batiatus has commented "Cool" on a task with the title "Typos"

    When I go to the comments page
    Then I should see "Batiatus commented on the task Typos:"
    And I should see "Cool"

  Scenario: See most recent comments on the Editor's Panel
    When I go to the Editor's Panel page
    Then I should see "Most recent comments"
    And I should see "No comments."
