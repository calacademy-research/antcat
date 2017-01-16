Feature: Searching references
  As a user of AntCat
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given these references exist
      | authors        | year | citation_year | title                 | citation   |
      | Fisher, B.     | 1995 | 1995          | Anthill               | Ants 1:1-2 |
      | Hölldobler, B. | 1995 | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.     | 2010 | 2010 ("2011") | Ants of North America | Ants 2:1-2 |

  Scenario: Not searching yet
    When I go to the references page
    Then I should see "Fisher, B."
    And I should see "Hölldobler, B."
    And I should see "Bolton, B."

  @search
  Scenario: Finding one reference for an author
    When I go to the references page
    And I fill in the references search box with "Fisher"
    And I press "Go" by the references search box
    Then I should see "Fisher, B."
    And I should not see "Bolton, B."
    And I should not see "Hölldobler, B."

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
    Then I should not see "Fisher, B."
    And I should not see "Bolton, B."
    And I should not see "Hölldobler, B."
    And I should see "No results found"

  @search
  Scenario: Maintaining search box contents
    When I go to the references page
    And I fill in the references search box with "zzzzzz year:1972-1980"
    And I press "Go" by the references search box
    Then I should see "No results found"
    And the "q" field should contain "zzzzzz year:1972-1980"

  @search
  Scenario: Searching by year
    When I go to the references page
    And I fill in the references search box with "1995"
    And I press "Go" by the references search box
    Then I should see "Fisher, B. 1995"
    And I should see "Hölldobler, B. 1995b"
    And I should not see "Bolton, B. 2010"

  @search
  Scenario: Searching by a year range
    Given these references exist
      | year | citation_year | authors | title  | citation    |
      | 2009 | 2009a         | authors | title1 | Ants 31:1-2 |
      | 2010 | 2010c         | authors | title2 | Ants 32:1-2 |
      | 2011 | 2011d         | authors | title3 | Ants 33:1-2 |
      | 2012 | 2012e         | authors | title4 | Ants 34:1-2 |

    When I go to the references page
    And I fill in the references search box with "year:2010-2011"
    And I press "Go" by the references search box
    Then I should see "2010c."
    And I should see "2011d."
    And I should not see "2009a."
    And I should not see "2012e."

  @search
  Scenario: Searching by author and year
    Given these references exist
      | authors    | year | citation_year | title  | citation    |
      | Fisher, B. | 1895 | 1895a         | title5 | Ants 11:1-2 |
      | Fisher, B. | 1810 | 1810b         | title6 | Ants 12:1-2 |
      | Bolton, B. | 1810 | 1810e         | title7 | Ants 13:1-2 |
      | Bolton, B. | 1895 | 1895d         | title8 | Ants 14:1-2 |

    When I go to the references page
    And I fill in the references search box with "fisher year:1895-1895"
    And I press "Go" by the references search box
    Then I should see "Fisher, B. 1895"
    And I should not see "Fisher, B. 1810"
    And I should not see "Bolton, B. 1810"
    And I should not see "Bolton, B. 1895"

  Scenario: Searching by ID
    Given there is a reference with ID 50000 for Dolerichoderinae

    When I go to the references page
    And I fill in the references search box with "50000"
    And I press "Go" by the references search box
    Then I should see "Dolerichoderinae"

    When I go to the references page
    And I fill in the references search box with "10000"
    And I press "Go" by the references search box
    Then I should not see "Dolerichoderinae"

  @search
  Scenario: Seeing just "other" references (not article, book, etc.)
    Given this reference exists
      | authors    | year | title | citation      |
      | Fisher, B. | 1895 | Known | Psyche 11:1-2 |
    And this unknown reference exists
      | authors    | year | title   | citation       |
      | Bolton, B. | 2001 | Unknown | Science 11:1-2 |

    When I go to the references page
    Then I should see "Known"
    And I should see "Unknown"

    When I fill in the references search box with "type:unknown"
    And I press "Go" by the references search box
    Then I should not see "Known"
    And I should see "Unknown"

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
      | authors    | year | title         | citation      |
      | Fisher, B. | 1995 | Anthill       | Ants 1:1-2    |
      | Bolton, B. | 1895 | Fisher's Ants | Psyche 11:1-2 |

    When I go to the references page
    And I fill in the references search box with "author:fish"
    Then I should see the following autocomplete suggestions:
      | Anthill |
    And I should not see the following autocomplete suggestions:
      | Fisher's Ants |

  @javascript @search
  Scenario: Search using autocomplete keywords (that are not well formatted)
    Given these references exists
      | authors    | year | title         | citation      |
      | Fisher, B. | 1995 | Anthill       | Ants 1:1-2    |
      | Bolton, B. | 1895 | Fisher's Ants | Psyche 11:1-2 |

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
