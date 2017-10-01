Feature: Searching the catalog
  Background:
    Given subfamily "Dolichoderinae" exists
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And species "Dolichoderus major" exists in that genus
    And subgenus "Dolichoderus (Subdolichoderus)" exists in that genus
    And species "Dolichoderus (Subdolichoderus) abruptus" exists in that subgenus
    And subspecies "Dolichoderus (Subdolichoderus) abruptus minor" exists in that species
    And I go to the catalog

  Scenario: Searching when no results
    When I fill in the catalog search box with "zxxz"
    And I press "Go" by the catalog search box
    Then I should see "No results found."

  Scenario: Searching when only one result
    When I fill in the catalog search box with "Dolichoderini"
    And I press "Go" by the catalog search box
    Then I should be on the catalog page for "Dolichoderini"

  Scenario: Searching when more than one result
    When I fill in the catalog search box with "doli"
    And I press "Go" by the catalog search box
    Then I should see "Dolichoderinae" in the search results
    And I should see "Dolichoderini" in the search results`
    And I should see "Dolichoderus" in the search results`

  Scenario: Searching for a 'containing' match
    When I fill in the catalog search box with "rup"
    And I press "Go" by the catalog search box
    Then I should see "No results"

    When I select "Containing" from "search_type"
    And I press "Go" in "#quick_search"
    Then I should see "Dolichoderus (Subdolichoderus) abruptus"

  Scenario: Following a search result
    When I fill in the catalog search box with "doli"
    And I press "Go" by the catalog search box
    And I follow "Dolichoderini" in the search results
    Then I should see "Dolichoderini history"

  Scenario: Searching for full species name, not just epithet
    When I fill in the catalog search box with "Dolichoderus major "
    And I press "Go" by the catalog search box
    Then I should see "Dolichoderus major history"

  Scenario: Searching for subspecies
    When I fill in the catalog search box with "minor"
    And I press "Go" by the catalog search box
    Then I should see "minor history"

  Scenario: Searching for subgenus
    When I fill in the catalog search box with "Subdol"
    And I press "Go" by the catalog search box
    Then I should see "Dolichoderus (Subdolichoderus) history"

  @javascript
  Scenario: Search using autocomplete
    When I fill in the catalog search box with "majo"
    Then I should see the following autocomplete suggestions:
      | Dolichoderus major |
    And I should not see the following autocomplete suggestions:
      | Dolichoderini |
