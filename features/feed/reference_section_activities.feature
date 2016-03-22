@feed
Feature: Feed (reference sections)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added reference section
    When I add a reference section for the feed
    And I go to the activity feed
    Then I should see "Archibald added the reference section" and no other feed items

  Scenario: Edited reference section
    When I edit a reference section for the feed
    And I go to the activity feed
    Then I should see "Archibald edited the reference section" and no other feed items

  Scenario: Deleted reference section
    When I delete a reference section for the feed
    And I go to the activity feed
    Then I should see "Archibald deleted the reference section" and no other feed items
