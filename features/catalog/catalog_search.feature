Feature: Searching the catalog
  Background:
    Given there is a species "Lasius niger"
    And I go to the catalog

  Scenario: Searching when no results
    When I fill in "qq" with "zxxz" within the desktop menu
    And I click on the catalog search button
    Then I should see "No results found."

  Scenario: Searching with results
    Given there is a species "Formica niger"

    When I fill in "qq" with "niger" within the desktop menu
    And I click on the catalog search button
    Then I should see "Formica niger" within the search results
    And I should see "Lasius niger" within the search results

  Scenario: Searching for an exact match
    When I fill in "qq" with "Lasius niger" within the desktop menu
    And I click on the catalog search button
    Then I should be on the catalog page for "Lasius niger"
    And I should see "You were redirected to an exact match"
    And I should see "Show more results"
