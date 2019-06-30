Feature: Searching the catalog
  Background:
    Given there is a species "Lasius niger"
    And I go to the catalog

  Scenario: Searching when no results
    When I fill in the catalog search box with "zxxz"
    And I press the search button by the catalog search box
    Then I should see "No results found."

  Scenario: Searching with results
    Given there is a species "Formica niger"

    When I fill in the catalog search box with "niger"
    And I press the search button by the catalog search box
    Then I should see "Formica niger" in the search results
    And I should see "Lasius niger" in the search results

  Scenario: Searching for an exact match
    When I fill in the catalog search box with "Lasius niger"
    And I press the search button by the catalog search box
    Then I should be on the catalog page for "Lasius niger"
    And I should see "You were redirected to an exact match"
    And I should see "Show more results"

  @javascript
  Scenario: Search using autocomplete
    Given there is a species "Lasius flavus"

    When I fill in the catalog search box with "nig"
    Then I should see the following autocomplete suggestions:
      | Lasius niger |
    And I should not see the following autocomplete suggestions:
      | Lasius flavus |
