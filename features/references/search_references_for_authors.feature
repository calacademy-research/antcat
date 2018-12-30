Feature: Search references for authors
  Background:
    Given these references exist
      | author     | title         |
      | Forel, M.  | Forel's Ants  |
      | Bolton, B. | Bolton's Ants |
    And a Bolton-Fisher reference exists with the title "Bolton and Fisher's Ants"
    And I go to the main page

  @search
  Scenario: Searching for one author only (keyword search)
    When I fill in the references search box with "author:'Bolton, B.'"
    And I press "Go" by the references search box
    Then I should see "Bolton and Fisher's Ants"
    And I should see "Bolton's Ants"
    And I should not see "Forel's Ants"

  @javascript @search
  Scenario: Searching for multiple authors (via the search type select)
    When I fill in the references search box with "bol"
    Then I should see the following autocomplete suggestions:
      | Bolton, B. |
    And I should not see the following autocomplete suggestions:
      | Forel, M. |

    When I follow "Bolton, B."
    Then I should see "Bolton and Fisher's Ants"
    And I should see "Bolton's Ants"
    And I should not see "Forel's Ants"
