@search
Feature: Search references for authors
  Background:
    Given these references exist
      | authors               | year | citation_year | title   | citation   |
      | Fisher, B.;Bolton, B. | 1995 | 1995b         | Anthill | Ants 1:1-2 |
      | Forel, M.             | 1995 | 1995b         | Formis  | Ants 1:1-2 |
      | Bolton, B.            | 2010 | 2010          | Antz    | Ants 2:1-2 |
    And I go to the references page

  Scenario: Searching for one author only (keyword search)
    When I fill in the references search box with "author:'Bolton, B.'"
    And I press "Go" by the references search box
    Then I should see "Anthill"
    And I should see "Antz"
    And I should not see "Formis"

  Scenario: Searching for multiple authors (via the search type select)
    When I select author search from the search type selector
    And I fill in the references authors search box with "Bolton, B.; Fisher, B."
    And I press "Go" by the references search box
    Then I should see "Anthill"
    And I should not see "Antz"
    And I should not see "Formis"

  Scenario: Unparsable author name (via the search type select)
    When I select author search from the search type selector
    And I fill in the references authors search box with "123"
    And I press "Go" by the references search box
    Then I should see "Could not parse author names"
