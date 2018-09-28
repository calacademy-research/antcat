Feature: Searching references
  Background:
    Given these references exist
      | author         | title             |
      | Hölldobler, B. | Hölldobler's Ants |
      | Fisher, B.     | Fisher's Ants     |
    And I go to the references page

  @search
  Scenario: Searching for an author name with diacritics, using the diacritics in the query
    When I fill in the references search box with "Hölldobler"
    And I press "Go" by the references search box
    Then I should see "Hölldobler, B."
    Then I should not see "Fisher, B."

  Scenario: Finding nothing
    When I fill in the references search box with "zzzzzz"
    And I press "Go" by the references search box
    And I should see "No results found"

  Scenario: Maintaining search box contents
    When I fill in the references search box with "zzzzzz year:1972-1980"
    And I press "Go" by the references search box
    Then I should see "No results found"
    And the "reference_q" field should contain "zzzzzz year:1972-1980"

  @javascript @search
  Scenario: Search using autocomplete
    When I fill in the references search box with "hol"
    Then I should see the following autocomplete suggestions:
      | Hölldobler's Ants |
    And I should not see the following autocomplete suggestions:
      | Fisher's Ants |

  @javascript @search
  Scenario: Search using autocomplete keywords
    When I fill in the references search box with "author:fish"
    Then I should see the following autocomplete suggestions:
      | Fisher's Ants |
    And I should not see the following autocomplete suggestions:
      | Hölldobler's Ants |

  @javascript @search
  Scenario: Expanding autocomplete suggestions
    When I fill in the references search box with "author:fish"
    Then I should see the following autocomplete suggestions:
      | Fisher's Ants |

    When I click the first autocomplete suggestion
    Then the search box should contain "author:'Fisher, B.'"
