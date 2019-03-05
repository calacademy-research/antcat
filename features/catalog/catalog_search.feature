Feature: Searching the catalog
  Background:
    Given there is a subfamily "Dolichoderinae"
    And there is a species "Dolichoderus major" with genus "Dolichoderus"
    And I go to the catalog

  Scenario: Searching when no results
    When I fill in the catalog search box with "zxxz"
    And I press the search button by the catalog search box
    Then I should see "No results found."

  Scenario: Searching for a 'beginning with' match
    When I fill in the catalog search box with "doli"
    And I press the search button by the catalog search box
    Then I should see "Dolichoderinae" in the search results
    And I should see "Dolichoderus" in the search results
    And I should not see "Dolichoderus major" in the search results

  Scenario: Searching for a 'containing' match
    When I fill in the catalog search box with "jor"
    And I press the search button by the catalog search box
    Then I should see "No results"

    When I select "Containing" from "search_type"
    And I press "Go" in "#quick_search"
    Then I should see "Dolichoderus major"

  @javascript
  Scenario: Search using autocomplete
    When I fill in the catalog search box with "majo"
    Then I should see the following autocomplete suggestions:
      | Dolichoderus major |
    And I should not see the following autocomplete suggestions:
      | Dolichoderini |
