Feature: Searching the catalog
  As a user of AntCat
  I want to search the catalog in index view
  So that I can find taxa with their parents and siblings

  Background: 
    Given the Formicidae family exists
    And subfamily "Dolichoderinae" exists
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And species "Dolichoderus major" exists in that genus
    And subgenus "Dolichoderus (Subdolichoderus)" exists in that genus
    And species "Dolichoderus (Subdolichoderus) abruptus" exists in that subgenus
    And subspecies "Dolichoderus (Subdolichoderus) abruptus minor" exists in that species

  Scenario: Searching when no results
    When I go to the catalog
    And I fill in the search box with "asdfjl;jsdf"
    And I press "Go" by the search box
    Then I should see "No results found"

  Scenario: Searching when only one result
    When I go to the catalog
    When I fill in the search box with "abruptus"
    And I press "Go" by the search box
    Then I should see "abruptus history"

  Scenario: Searching when more than one result
    When I go to the catalog
    And I fill in the search box with "doli"
    And I press "Go" by the search box
    Then I should see "Dolichoderinae" in the search results
    And I should see "Dolichoderini" in the search results`
    And I should see "Dolichoderus" in the search results`
    And "Dolichoderinae" should be selected in the search results
    And "Dolichoderinae" should be selected in the index
    And I should see "Dolichoderinae history"

  Scenario: Searching for a 'containing' match
    When I go to the catalog
    And I fill in the search box with "rup"
    And I select "containing" from "search_type"
    And I press "Go" by the search box
    Then I should see "abruptus history"

  Scenario: Following a search result
    When I go to the catalog
    And I follow "show tribes"
    And I fill in the search box with "doli"
    And I press "Go" by the search box
    And I follow "Dolichoderini" in the search results
    Then I should see "Dolichoderini history"
    And I should see "Dolichoderini" in the search results

  Scenario: Keeping search results open even after selecting another taxon
    When I go to the catalog
    And I follow "show tribes"
    And I fill in the search box with "doli"
    And I press "Go" by the search box
    And I follow "Dolichoderini" in the search results
    And I follow "Dolichoderinae" in the index
    Then I should see "Dolichoderini" in the search results

  Scenario: Closing the search results
    When I go to the catalog
    And I follow "show tribes"
    And I fill in the search box with "doli"
    And I press "Go" by the search box
    And I follow "Dolichoderini" in the search results
    And I press "Clear"
    Then I should not see any search results
    And "Dolichoderini" should be selected in the index

  Scenario: Finding a genus without a subfamily or a tribe
    Given a genus exists with a name of "Monomorium" and no subfamily and a taxonomic history of "Monomorium history"
    When I go to the catalog
    And I fill in the search box with "Monomorium"
    And I press "Go" by the search box
    Then I should see "Monomorium history"
    And "(no subfamily)" should be selected in the subfamilies index
    And "Monomorium" should be selected in the genera index

  Scenario: Finding a genus without a tribe but with a subfamily
    Given a genus exists with a name of "Monomorium" and a subfamily of "Dolichoderinae" and a taxonomic history of "Monomorium history"
    When I go to the catalog
    And I follow "show tribes"
    And I fill in the search box with "Monomorium"
    And I press "Go" by the search box
    Then I should see "Monomorium history"
    And "Dolichoderinae" should be selected in the subfamilies index
    And "(no tribe)" should be selected in the tribes index
    And "Monomorium" should be selected in the genera index

  #Scenario: Finding a tribe when tribes are hidden
    #When I go to the catalog
    #And I follow "show tribes"
    #And I follow "Dolichoderinae"
    #And I follow "hide" in the tribes index
    #And I fill in the search box with "Dolichoderini"
    #And I press "Go" by the search box
    #Then I should see "Dolichoderini" in the tribes index
    #And "Dolichoderini" should be selected in the tribes index

  Scenario: Searching with spaces at beginning and/or end of query string
    When I go to the catalog
    When I fill in the search box with " abruptus "
    And I press "Go" by the search box
    Then I should see "abruptus history"

  Scenario: Searching for full species name, not just epithet
    When I go to the catalog
    When I fill in the search box with "Dolichoderus major "
    And I press "Go" by the search box
    Then I should see "Dolichoderus major history"

  Scenario: Searching for subspecies
    When I go to the catalog
    When I fill in the search box with "minor"
    And I press "Go" by the search box
    Then I should see "minor history"

  Scenario: Searching for subgenus
    When I go to the catalog
    When I fill in the search box with "Subdol"
    And I press "Go" by the search box
    Then I should see "Dolichoderus (Subdolichoderus) history"
