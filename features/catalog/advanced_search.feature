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

  Scenario: Searching for an author's descriptions
    Given there is a species described in 2010 by "Bolton"
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "1 result found"
    And I should see the species described in 2010

  Scenario: Finding an original combination
    Given there is an original combination of "Atta major" described by "Bolton" which was moved to "Betta major"
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "see Betta major"

  Scenario: Finding a junior synonym
    Given there is a species "Atta major" described by "Bolton" which is a junior synonym of "Betta minor"
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "synonym of Betta minor"

  Scenario: Manually entering a name instead of using picklist
    Given there is a species described in 2010 by "Bolton, B."
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "No results found"

