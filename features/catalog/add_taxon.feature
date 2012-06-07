@javascript @editing
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept accurate
  So people use AntCat

 #Background:
    #Given the Formicidae family exists
    #And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Dolichoderinae history"
    #And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dolichoderini history"

  #Scenario: Adding a genus
    #When I go to the catalog
    #* I follow "Dolichoderinae" in the subfamilies index
    #* I follow "Dolichoderini" in the tribes index
    #* I follow "add" in the genera index
    #Then I should see "Adding genus to Dolichoderini"
    #When I set the genus name to "Atta"
    #And I add a reference and choose it for the protonym
    #* I save my changes
    ##Then I should see "Atta" in the genera index

  #Scenario: Trying to add a genus with a blank name
    #When I go to the catalog
    #* I follow "Dolichoderinae" in the subfamilies index
    #* I follow "Dolichoderini" in the tribes index
    #* I follow "add" in the genera index
    #* I set the genus name to ""
    #* I save my changes
    #Then I should see "Name can't be blank"
