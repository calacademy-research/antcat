@feed
Feature: Feed (tasks)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added task
    When I go to the open tasks page
    And I follow "New"
    And I fill in "task_title" with "Valid?"
    And I fill in "task_description" with "Ids #999 and #777"
    And I press "Save"

    When I go to the activity feed
    Then I should see "Archibald added the task Valid?"

  Scenario: Edited task
    Given there is an open task for the feed

    When I go to the open tasks page
    And I follow "Valid?"
    And I follow "Edit"
    And I fill in "task_description" with "Are these valid?"
    And I press "Save"

    When I go to the activity feed
    Then I should see "Archibald edited the task Valid?"

  Scenario: Completed a task
    Given there is an open task for the feed

    When I go to the open tasks page
    And I follow "Valid?"
    And I follow "Complete"

    When I go to the activity feed
    Then I should see "Archibald completed the task Valid?"

  Scenario: Closed a task
    Given there is an open task for the feed

    When I go to the open tasks page
    And I follow "Valid?"
    And I follow "Close"

    When I go to the activity feed
    Then I should see "Archibald closed the task Valid?"

  Scenario: Re-opened a closed task
    Given there is a closed task for the feed

    When I go to the open tasks page
    And I follow "Valid?"
    And I follow "Re-open"

    When I go to the activity feed
    Then I should see "Archibald re-opened the task Valid?"
