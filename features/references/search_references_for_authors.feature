Feature: Search references for authors
  Background:
    Given these references exist
      | author     | title         |
      | Forel, M.  | Forel's Ants  |
      | Bolton, B. | Bolton's Ants |
    And a Bolton-Fisher reference exists with the title "Bolton and Fisher's Ants"
    And I go to the references page

  @search
  Scenario: Searching for one author only (keyword search)
    When I fill in the references search box with "author:'Bolton, B.'"
    And I press "Go" by the references search box
    Then I should see "Bolton and Fisher's Ants"
    And I should see "Bolton's Ants"
    And I should not see "Forel's Ants"

  Scenario: Searching for multiple authors (via the search type select)
    When I select author search from the search type selector
    And I fill in the references authors search box with "Bolton, B.; Fisher, B."
    And I press "Go" by the references search box
    Then I should see "Bolton and Fisher's Ants"
    And I should not see "Bolton's Ants"
    And I should not see "Forel's Ants"

  Scenario: Unparsable author name (via the search type select)
    When I select author search from the search type selector
    And I fill in the references authors search box with "123"
    And I press "Go" by the references search box
    Then I should see "Could not parse author names"
