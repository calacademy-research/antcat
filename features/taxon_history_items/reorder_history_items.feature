@skip @javascript
Feature: Reorder history items
  As an editor of AntCat
  I want to change the order of taxonomic history items

  Background:
    Given I log in as a catalog editor named "Archibald"
    And there is a genus Orderia with the history items "AAA", "BBB" and "CCC"

  Scenario: Reordering a history item but cancelling
    When I go to the catalog page for "Orderia"
    Then I should see "AAA. BBB. CCC."

    When I go to the edit page for "Orderia"
    Then I should not see "Drag and drop history items to reorder them"

    When I click on Reorder in the history section
    Then I should see "Drag and drop"

    When I drag the AAA history item a bit
    Then I should see "BBB. AAA. CCC."
    And I click on Cancel in the history section
    Then I should not see "Drag and drop"

    When I go to the catalog page for "Orderia"
    Then I should see "AAA. BBB. CCC."

  Scenario: Reordering a history item (with feed)
    When I go to the edit page for "Orderia"
    And I click on Reorder in the history section
    And I drag the AAA history item a bit
    Then I should see "BBB. AAA. CCC."

    When I click on Save new order in the history section
    Then I should not see "Drag and drop"

    When I go to the catalog page for "Orderia"
    Then I should see "BBB. AAA. CCC."

    When I go to the activity feed
    Then I should see "Archibald reordered the history items of Orderia" in the feed
    And I should not see "Order was changed from"

    When I click on Show more
    Then I should see "Order was changed from"
