@javascript @chrome_only
Feature: Reorder history items
  As an editor of AntCat
  I want to change the order of taxonomic history items

  Background:
    And I am logged in
    Given there is a genus Orderia with the history items "AAA", "BBB" and "CCC"

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

  Scenario: Reordering a history item
    When I go to the edit page for "Orderia"
    And I click on Reorder in the history section
    And I drag the AAA history item a bit
    Then I should see "BBB. AAA. CCC."

    When I click on Save new order in the history section
    Then I should not see "Drag and drop"

    When I go to the catalog page for "Orderia"
    Then I should see "BBB. AAA. CCC."
