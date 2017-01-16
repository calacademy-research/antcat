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

  @javascript @chrome_only
  Scenario: Reorded taxon history items
    Given there is a genus Orderia with the history items "AAA", "BBB" and "CCC"

    When I go to the edit page for "Orderia"
    And I click on Reorder in the history section
    And I drag the AAA history item a bit
    And I click on Save new order in the history section
    Then I should not see "Drag and drop"

    When I go to the activity feed
    Then I should see "Archibald reordered the history items of Orderia" and no other feed items
    And I should not see "Order was changed from"

    When I click on Show more
    Then I should see "Order was changed from"
