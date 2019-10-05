Feature: Searching the catalog
  Background:
    Given I go to the advanced search page

  Scenario: Searching when no results
    When I fill in "year" with "2010"
    And I press "Search"
    Then I should see "No results"

  Scenario: Searching for subfamilies
    Given there is a subfamily "Formicinae"

    When I select "Subfamily" from "type"
    And I press "Search"
    Then I should see "1 result"

  Scenario: Searching for valid taxa
    Given there is an invalid family

    When I check "valid_only"
    And I press "Search"
    Then I should see "No results"

  Scenario: Searching for an author's descriptions
    Given there is a species described by Bolton

    When I fill in "author_name" with "Bolton"
    And I press "Search"
    Then I should see "1 result"

  Scenario: Finding a genus
    Given there is a species "Atta major" in the genus "Atta"

    When I fill in "genus" with "Atta"
    And I press "Search"
    Then I should see "Atta major"

  Scenario: Searching for locality
    Given there is a genus located in "Mexico"
    And there is a genus located in "Zimbabwe"

    When I fill in "locality" with "Mexico"
    And I press "Search"
    Then I should see "1 result"
    And I should see "MEXICO" within the search results

  Scenario: Searching for biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region "Afrotropic"

    When I select "Afrotropic" from "biogeographic_region"
    And I press "Search"
    Then I should see "2 results"
    And I should see "Afrotropic" within the search results

  Scenario: Searching for 'None' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region ""

    When I select "Species" from "type"
    And I select "None" from "biogeographic_region"
    And I press "Search"
    Then I should see "1 result"

  Scenario: Searching in type fields
    Given there is a species with primary type information "Madagascar: Prov. Toliara"

    When I fill in "type_information" with "Toliara"
    And I press "Search"
    Then I should see "1 result"

  Scenario: Searching for a form
    Given there is a species with forms "w.q."
    And there is a species with forms "q."

    When I fill in "forms" with "w."
    And I press "Search"
    Then I should see "1 result"
    And I should see "w." within the search results

  Scenario: Searching for 'described in' (range)
    Given there is a species described in 2010
    And there is a species described in 2011
    And there is a species described in 2012

    When I fill in "year" with "2010-2011"
    And I press "Search"
    Then I should see "2 result"
    And I should see "2010" within the search results
    And I should see "2011" within the search results

  Scenario: Download search results
    Given there is a species described in 2010

    When I fill in "year" with "2010"
    And I press "Search"
    And I follow "Download"
    Then I should get a download with the filename "antcat_search_results__" and today's date
