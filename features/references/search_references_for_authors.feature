Feature: Search references for authors
  As any old user of AntCat
  I want to do more than just search for text/year/id/author in one field
  I want to be able to specify author names and have them only searched for
    in the author names
  And so on
  So that I can quickly find a reference

  @search
  Scenario: Searching for one author only
    Given I am logged in
    And these references exist
      | authors               | year | citation_year | title                 | citation   |
      | Fisher, B.;Bolton, B. | 1995 | 1995b         | Anthill               | Ants 1:1-2 |
      | Forel, M.             | 1995 | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.            | 2010 | 2010          | Ants of North America | Ants 2:1-2 |
    When I go to the references page
    And I fill in the references search box with "author:'Bolton, B.'"
    And I press "Go" by the references search box
    Then I should see "Anthill"
    And I should see "Ants of North America"
    And I should not see "Formis"

  @search
  Scenario: Searching for multiple authors
    Given I am logged in
    And these references exist
      | authors               | year | citation_year | title                 | citation   |
      | Fisher, B.;Bolton, B. | 1995 | 1995b         | Anthill               | Ants 1:1-2 |
      | Forel, M.             | 1995 | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.            | 2010 | 2010          | Ants of North America | Ants 2:1-2 |
    When I go to the references page
    And I fill in the references search box with "author:'Bolton, B.; Fisher, B.'"
    And I press "Go" by the references search box
    Then I should see "Anthill"
    And I should not see "Ants of North America"
    And I should not see "Formis"