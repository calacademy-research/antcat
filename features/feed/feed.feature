@feed
Feature: Feed
  As an AntCat editor
  I want to see what has changed in the database

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: No activities
    When I go to the activity feed
    Then I should see "No activities"

  Scenario: Deleting activities
    Given I log in as a superadmin
    And I add a journal for the feed

    When I go to the activity feed
    Then I should see 1 item in the feed

    When I follow "Delete"
    Then I should see "No activities"

  Scenario: Only superadmins should be able to delete feed items
    Given I add a journal for the feed

    When I go to the activity feed
    Then I should see 1 item in the feed
    Then I should not see "Delete"
