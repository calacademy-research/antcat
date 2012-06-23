Feature: Using the catalog index
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background: 
    Given the Formicidae family exists
    And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
    And a genus exists with a name of "Atta" and no subfamily and a taxonomic history of "Atta history"
    And a fossil genus exists with a name of "Brownerus" and a tribe of "Dolichoderini" and a taxonomic history of "Dolichoderus history"
    And a species exists with a name of "abruptus" and a genus of "Dolichoderus" and a taxonomic history of "abruptus history"
    And a subspecies exists for that species with a name of "Dolichoderus abruptus minor" and an epithet of "minor" and a taxonomic history of "minor history"
    And a genus exists with a name of "Camponotus" and a subfamily of "Dolichoderinae" and a taxonomic history of "Campononotus history"
    And a subgenus exists with a name of "Subcamponotus" and a genus of "Camponotus" and a taxonomic history of "Subcamponotus history"
    And a species exists with a name of "subabruptus" and a subgenus of "Camponotus (Subcamponotus)" and a taxonomic history of "subabruptus history"

  #Scenario: Selecting a subgenus
    #When I go to the catalog index
    #And I follow "Dolichoderinae"
    #And I follow "Dolichoderini"
    #And I follow "Dolichoderus"
    #And I follow "Subdolichoderus"
    #Then "Dolichoderinae" should be selected
    #And "Dolichoderini" should be selected
    #And "Dolichoderus" should be selected
    #And "Subdolichoderus" should be selected
    #And I should see "Subdolichoderus history"
    #And I should see "1 valid species, 1 valid subspecies"
    #And I should see "abruptus" in the index
    #And I should see "minor" in the index
