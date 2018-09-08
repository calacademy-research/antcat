Feature: Searching the catalog
  Background:
    Given subfamily "Dolichoderinae" exists
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And species "Dolichoderus major" exists in that genus
    And I go to the catalog

  Scenario: Searching when no results
    When I fill in the catalog search box with "zxxz"
    And I press "Go" by the catalog search box
    Then I should see "No results found."

  Scenario: Searching for a 'containing' match
    When I fill in the catalog search box with "jor"
    And I press "Go" by the catalog search box
    Then I should see "No results"

    When I select "Containing" from "search_type"
    And I press "Go" in "#quick_search"
    Then I should see "Dolichoderus major"

  Scenario: Following a search result
    When I fill in the catalog search box with "doli"
    And I press "Go" by the catalog search box
    Then I should see "Dolichoderinae" in the search results
    And I should see "Dolichoderini" in the search results
    And I should see "Dolichoderus" in the search results

    When I follow "Dolichoderini" in the search results
    Then I should see "Dolichoderini" in the header

  Scenario: Searching for full species name, not just epithet
    When I fill in the catalog search box with "Dolichoderus major "
    And I press "Go" by the catalog search box
    Then I should see "Dolichoderus major" in the header

  Scenario: Searching for subgenus
    Given subgenus "Dolichoderus (Subdolichoderus)" exists in that genus

    When I fill in the catalog search box with "Subdol"
    And I press "Go" by the catalog search box
    Then I should see "(Subdolichoderus)" in the header

  @javascript
  Scenario: Search using autocomplete
    When I fill in the catalog search box with "majo"
    Then I should see the following autocomplete suggestions:
      | Dolichoderus major |
    And I should not see the following autocomplete suggestions:
      | Dolichoderini |
