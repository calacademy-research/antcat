Feature: Using the Taxatry index
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
      And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"
      And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
      And a species exists with a name of "abruptus" and a genus of "Dolichoderus" and a taxonomic history of "abruptus history"
      #And a genus exists with a name of "Tapinoma" and a subfamily of "Dolichoderinae" and a taxonomic history of "Tapinoma history" and a status of "synonym"
      #And a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae" and a taxonomic history of "Atta history"
      #And a genus exists with a name of "Tetramorium" and a subfamily of "Dolichoderinae"
      #And a genus exists with a name of "Myrmicium" and no subfamily and a taxonomic history of "Myrmicium history"
      #And a species exists with a name of "shattucki" and a genus of "Myrmicium" and a taxonomic history of "Myrmicium shattucki history"
      #And a species exists with a name of "attaxus" and a genus of "Tetramorium" and a taxonomic history of "Tetramorium attaxus history"
      #And a species exists with a name of "sessile" and a genus of "Tapinoma" and a taxonomic history of "sessile history"
      #And a species exists with a name of "emeryi" and a genus of "Tapinoma" and a taxonomic history of "emeryi history"
      #And a species exists with a name of "emeryi" and a genus of "Atta" and a taxonomic history of "atta emeryi history"

  Scenario: Before selecting anything
    When I go to the Taxatry index
    Then I should see "Dolichoderinae" in the index
      And I should not see "Dolichoderinae history"

  Scenario: Selecting a subfamily
    When I go to the Taxatry index
      And I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
      And I should see "Dolichoderinae history"
      And I should see "Dolichoderini" in the index
      #And I should see "2 valid genera (1 synonym)"

  Scenario: Selecting a tribe
    When I go to the Taxatry index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And I should see "Dolichoderini history"
      #And I should see "2 valid genera (1 synonym)"
      And I should see "Dolichoderus" in the index

  Scenario: Selecting a genus
    When I go to the Taxatry index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "Dolichoderus"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And "Dolichoderus" should be selected
      And I should see "Dolichoderus history"
      #And I should see "2 valid genera (1 synonym)"
      And I should see "abruptus" in the index

  Scenario: Selecting a species
    When I go to the Taxatry index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "Dolichoderus"
      And I follow "abruptus"
    Then "Dolichoderinae" should be selected
      And "Dolichoderini" should be selected
      And "Dolichoderus" should be selected
      And "abruptus" should be selected
      And I should see "abruptus history"

  Scenario: Showing the "incertae sedis" subfamily
    Given a genus exists with a name of "Cariridris" and no subfamily
    When I go to the Taxatry index
      And I follow "(incertae sedis)"
    Then I should see "Cariridris"
      And "(incertae sedis)" should be selected
      And I should not see "Tribes"
      And I should not see "show tribes"

  #Scenario: Selecting a genus without a tribe
    #When I follow "Dolichoderinae"
      #And I hide tribes
    #Then "Dolichoderinae" should be selected
    #When I follow "Tapinoma"
    #Then "Tapinoma" should be selected
      #And I should see "Tapinoma history"
      #And I should see "sessile"

  #Scenario: Searching taxatry when only one result
    #When I fill in the search box with "sessile"
      #And I press "Go" by the search box
    #Then I should see "sessile history"

  #Scenario: Searching taxatry when no results
    #When I fill in the search box with "asdfjl;jsdf"
      #And I press "Go" by the search box
    #Then I should see "No results found"

  #Scenario: Searching taxatry when more than one result
    #When I fill in the search box with "emeryi"
      #And I press "Go" by the search box
    #Then I should see "Tapinoma emeryi"
      #And I should see "Atta emeryi"
      #And I should see "emeryi history"
    #When I follow "Atta emeryi"
    #Then I should see "atta emeryi history"
      #And I should see "Tapinoma emeryi"
      #And "Atta emeryi" should be selected

  #Scenario: Searching taxatry for a 'beginning with' match
    #When I fill in the search box with "ses"
      #And I select "beginning with" from "search_type"
      #And I press "Go" by the search box
    #Then I should see "sessile history"

  #Scenario: Finding a genus without a subfamily
    #Given a genus exists with a name of "Monomorium" and no subfamily and a taxonomic history of "Monomorium history"
    #When I fill in the search box with "Monomorium"
      #And I press "Go" by the search box
    #Then I should see "Monomorium history"

  #Scenario: Closing the search results
    #When I fill in the search box with "emeryi"
      #And I press "Go" by the search box
    #Then I should see "Tapinoma emeryi"
      #And I should see "Atta emeryi"
      #And I should see "atta emeryi history"
    #When I press "Clear"
    #Then I should see "atta emeryi history"
      #And I should not see "Tapinoma emeryi"

  #Scenario: Keeping search results open even after finding another taxon
    #When I fill in the search box with "emeryi"
      #And I press "Go" by the search box
    #Then I should see "Tapinoma emeryi"
      #And I should see "Atta emeryi"
      #And I should see "atta emeryi history"
    #When I follow "emeryi"
    #Then I should see "atta emeryi history"
      #And I should see "Tapinoma emeryi"

  #Scenario: Keeping search results after going to the browser
    #When I fill in the search box with "emeryi"
      #And I press "Go" by the search box
      #And I choose "Browser"
    #Then I should see "Tapinoma emeryi" within the search results
      #And I should see "Atta emeryi" within the search results

  #Scenario: Following a search result
    #When I fill in the search box with "Att"
      #And I press "Go" by the search box
    #Then I should see "Atta" in the search results
      #And I should see "Tetramorium attaxus" in the search results
      #And I should not see "Tetramorium attaxus history"
    #When I follow "Tetramorium attaxus"
      #Then I should see "Tetramorium attaxus history"
      #And I should be in "Index" mode

  #Scenario: Finding a genus without a subfamily
    #When I fill in the search box with "myrmi"
      #And I press "Go" by the search box
    #Then I should see "Myrmicium history"

  #Scenario: Selecting a species from a genus without a subfamily
    #When I fill in the search box with "myrmi"
      #And I press "Go" by the search box
      #And I follow "shattucki"
    #Then I should see "Myrmicium shattucki history"
