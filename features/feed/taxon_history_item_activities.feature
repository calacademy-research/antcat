@feed
Feature: Feed (taxon history items)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added taxon history item
    When I add a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald added the taxon history item #" and no other feed items
    And I should see "belonging to Dolichoderinae"

  Scenario: Edited taxon history item
    When I edit a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald edited the taxon history item #" and no other feed items
    And I should see "belonging to Dolichoderinae"

  Scenario: Deleted taxon history item
    When I delete a taxon history item for the feed
    And I go to the activity feed
    Then I should see "Archibald deleted the taxon history item #" and no other feed items
    And I should see "belonging to Dolichoderinae"
