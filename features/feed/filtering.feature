@feed
Feature: Feed (filtering)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Filtering activities by action
    Given I add a journal for the feed
    And I edit a journal for the feed

    When I go to the activity feed
    Then I should see 2 items in the feed

    When I select "Create" from "activity_action"
    And I press "Filter"
    Then I should see "Archibald added the journal Archibald Bulletin" and no other feed items

  Scenario: Showing/hiding automated edits
    Given there is an activity with the edit summary "Not automated"
    And there is an automated activity with the edit summary "Automated edit"

    When I go to the activity feed
    Then I should see "Not automated"
    And I should not see "Automated edit"

    When I check "show_automated_edits"
    And I press "Filter"
    Then I should see "Not automated"
    And I should see "Automated edit"
