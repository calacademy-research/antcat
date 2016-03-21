@feed
Feature: Feed (default template)
  As an AntCat editor
  I want to see what has changed in the database

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added taxon history item
    When I add a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald added the taxon history item"

  Scenario: Edited taxon history item
    When I edit a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald edited the taxon history item"

  Scenario: Deleted taxon history item
    When I delete a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald deleted the taxon history item"
