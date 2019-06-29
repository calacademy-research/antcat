Feature: Searching the catalog
  Background:
    Given I go to the advanced search page

  Scenario: Searching when no results
    When I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching for subfamilies
    Given there is a subfamily "Formicinae"

    When I select "Subfamily" from "type"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Searching for valid taxa
    Given there is an invalid family

    When I check valid only in the advanced search form
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching for an author's descriptions
    Given there is a species described by Bolton

    When I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Finding a genus
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Ophthalmopone major" with genus "Ophthalmopone"

    When I fill in "genus" with "Atta"
    And I press "Go" in the search section
    Then I should see "Atta major"

  Scenario: Manually entering an unknown name instead of using picklist
    When I fill in "author_name" with "asdasdasd"
    And I press "Go" in the search section
    Then I should see "If you're choosing an author, make sure you pick the name from the dropdown list."

  Scenario: Searching for locality
    Given there is a genus located in "Africa"
    And there is a genus located in "Zimbabwe"

    When I fill in "locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within the search results

  Scenario: Searching for biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region "Afrotropic"

    When I select "Afrotropic" from "biogeographic_region"
    And I press "Go" in the search section
    Then I should see "2 results"
    And I should see "Afrotropic" within the search results

  Scenario: Searching for 'None' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region ""

    When I select "Species" from "type"
    And I select "None" from "biogeographic_region"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Searching in type fields
    Given there is a species with primary type information "Madagascar: Prov. Toliara"

    When I fill in "type_information" with "Toliara"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Searching for a form
    Given there is a species with forms "w.q."
    And there is a species with forms "q."

    When I fill in "forms" with "w."
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "w." within the search results

  Scenario: Searching for 'described in' (range)
    Given there is a species described in 2010
    And there is a species described in 2011
    And there is a species described in 2012

    When I fill in "year" with "2010-2011"
    And I press "Go" in the search section
    Then I should see "2 result"
    And I should see "2010" within the search results
    And I should see "2010" within the search results

  Scenario: Download search results
    Given there is a species described in 2010

    When I fill in "year" with "2010"
    And I press "Go" in the search section
    And I follow "Download (advanced search only)"
    Then I should get a download with the filename "antcat_search_results__" and today's date
