Feature: Searching the catalog
  As a user of AntCat
  I want to search the catalog in index view
  So that I can find taxa with their parents and siblings

  Scenario: Searching when not logged in
    When I go to the catalog
    And I follow "Advanced Search"
    Then I should be on the advanced search page

  Scenario: Searching when no results
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "No results found"

  Scenario: Searching when one result
    Given there is a species described in 2010
    And there is a species described in 2011
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result found"
    And I should see the species described in 2010

  Scenario: Searching when more than one page of results
  # This passes even after changing WillPaginate::per_page
    #Given AntCat shows 3 species per page
    #And there were 4 species described in 2010
    #When I go to the catalog
    #And I follow "Advanced Search"
    #And I fill in "year" with "2010"
    #And I press "Go" in the search section
    #And show me the page
    #Then I should see "4 results found"

  Scenario: Searching for subfamilies
    Given there is a subfamily described in 2010
    When I go to the catalog
    And I follow "Advanced Search"
    And I select "Subfamilies" from the rank selector
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result found"
    And I should see the species described in 2010

  Scenario: Searching for an invalid taxon
    Given there is an invalid species described in 2010
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "year" with "2010"
    And I check "valid_only"
    And I press "Go" in the search section
    Then I should see "No results found"
