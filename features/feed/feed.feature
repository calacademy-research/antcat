Feature: Feed
  As an AntCat editor
  I want to see what has changed in the database

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: No activities
    When I go to the activity feed
    Then I should see "No activities"
