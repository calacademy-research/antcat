@feed
Feature: Feed (executed script)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Executed a script
    When I execute a script with the content "See %github999"
    And I go to the activity feed
    Then I should see "Archibald executed a script (See GitHub #999)"
