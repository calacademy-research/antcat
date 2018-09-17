Feature: Searching references
  Background:
    Given these references exist
      | author         | citation_year | title                 |
      | Fisher, B.     | 1995          | Anthill               |
      | Hölldobler, B. | 1995b         | Formis                |
      | Bolton, B.     | 2010 ("2011") | Ants of North America |

  Scenario: Not searching yet
    When I go to the references page
    Then I should see "Fisher, B."
    And I should see "Hölldobler, B."
    And I should see "Bolton, B."

  @search
  Scenario: Searching for an author name with diacritics, using the diacritics in the query
    When I go to the references page
    And I fill in the references search box with "Hölldobler"
    And I press "Go" by the references search box
    Then I should not see "Fisher, B."
    And I should not see "Bolton, B."
    And I should see "Hölldobler, B."

  @search
  Scenario: Finding nothing
    When I go to the references page
    And I fill in the references search box with "zzzzzz"
    And I press "Go" by the references search box
    And I should see "No results found"

  @search
  Scenario: Maintaining search box contents
    When I go to the references page
    And I fill in the references search box with "zzzzzz year:1972-1980"
    And I press "Go" by the references search box
    Then I should see "No results found"
    And the "reference_q" field should contain "zzzzzz year:1972-1980"

  @javascript @search
  Scenario: Search using autocomplete
    When I go to the references page
    And I fill in the references search box with "bolt"
    Then I should see the following autocomplete suggestions:
      | Ants of North America |
    And I should not see the following autocomplete suggestions:
      | Formis |
      | Anthill |

  @javascript @search
  Scenario: Search using autocomplete keywords
    Given these references exists
      | author     | title         |
      | Fisher, B. | Anthill       |
      | Bolton, B. | Fisher's Ants |

    When I go to the references page
    And I fill in the references search box with "author:fish"
    Then I should see the following autocomplete suggestions:
      | Anthill |
    And I should not see the following autocomplete suggestions:
      | Fisher's Ants |

  @javascript @search
  Scenario: Search using autocomplete keywords (that are not well formatted)
    Given these references exists
      | author     | title         |
      | Fisher, B. | Anthill       |
      | Bolton, B. | Fisher's Ants |

    When I go to the references page
    And I fill in the references search box with "Author: fish"
    Then I should see the following autocomplete suggestions:
      | Anthill |
    And I should not see the following autocomplete suggestions:
      | Fisher's Ants |

  @javascript @search
  Scenario: Expanding autocomplete suggestions
    When I go to the references page
    And I fill in the references search box with "author:fish"
    Then I should see the following autocomplete suggestions:
      | Anthill |

    When I click the first autocomplete suggestion
    Then the search box should contain "author:'Fisher, B.'"
