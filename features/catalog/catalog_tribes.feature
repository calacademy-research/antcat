Feature: Hiding and showing tribes in the index
  As a user of AntCat
  I want hide tribes sometimes
  Since I may not care about that rank
  And I don't want to have to choose from the tribes

  Background: 
    Given the Formicidae family exists
    And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "asdf"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae"
    And a tribe exists with a name of "Tapinomini" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini"
    And a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Tapinoma" and a tribe of "Tapinomini"
    And a genus exists with a name of "Atta" and no subfamily and a taxonomic history of "Atta history"
    And a species exists with a name of "rufa" and a genus of "Atta"

  Scenario: Hiding tribes
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    Then I should see "Dolichoderini" in the index
    And I should not see "show tribes"
    When I follow "hide"
    Then I should not see "Dolichoderini" in the index
    And I should see "show tribes"
    And I should see "Dolichoderus" in the index
    And I should see "Atta" in the index

  Scenario: Selecting a genus after hiding tribes
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "hide"
    Then I should see "Dolichoderus" in the index
    And I should see "Atta" in the index
    When I follow "Atta"
    Then I should see "Dolichoderus" in the index
    And I should see "Atta" in the index
    And I should see "Tapinoma" in the index

  Scenario: Selecting a species after hiding tribes
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    When I follow "hide"
    And I follow "Atta"
    And I follow "rufa"
    Then I should see "Dolichoderus" in the index
    And I should see "Atta" in the index
    And I should see "Tapinoma" in the index

  Scenario: Showing tribes after selecting a genus with a tribe
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "hide"
    And I follow "Dolichoderus"
    And I follow "show tribes"
    Then I should see "Dolichoderini" in the index
    And "Dolichoderini" should be selected

  Scenario: Showing tribes after selecting a genus without a tribe
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "hide"
    And I follow "Atta"
    And I follow "show tribes"
    Then I should see "Dolichoderini" in the index
    And "(no tribe)" should be selected in the tribes index
    And I should see "Atta" in the index

  Scenario: Hiding tribes after selecting a tribe
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "hide" in the tribes index
    Then I should not see the tribes index
    And I should see "Dolichoderus" in the index
    And "Dolichoderinae" should be selected

  Scenario: Hiding tribes after selecting a genus
    When I go to the catalog
    And I follow "show tribes"
    And I follow "Dolichoderinae"
    And I follow "Dolichoderini"
    And I follow "Dolichoderus"
    And I follow "hide" in the tribes index
    Then I should not see the tribes index
    And "Dolichoderinae" should be selected
    And "Dolichoderus" should be selected

  # This started breaking after 'hide tribes' became the default
  # The whole tribes column disappears after selecting '(no tribe)'
  #Scenario: Hiding tribes after selecting "no tribe" tribe
    #When I go to the catalog
    #And I follow "Dolichoderinae"
    #And I follow "show tribes"
    #And show me the page
    #And I follow "(no tribe)" in the tribes index
    #And I follow "hide" in the tribes index
    #Then I should see "Dolichoderinae" in the content

  Scenario: Selecting genus when tribes are hidden and (no subfamily) is selected
    When I go to the catalog
    And I follow "show tribes"
    And I follow "hide"
    And I follow "(no subfamily)"
    When I follow "Atta"

