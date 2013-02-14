@javascript @editing
Feature: Editing a history item
  #As an editor of AntCat
  #I want to change previously entered taxonomic history items
  #So that information is kept accurate and mistakes are fixed
  #So people use AntCat

  #Background:
    #Given the Formicidae family exists
    #And I am logged in as an editor and have editing turned on

  #Scenario: Editing a history item
    #When I go to the catalog with editing mode turned on
    #Then the history should be "Taxonomic history"
    #* I click the edit icon
    #* I edit the history item to "(none)"
    #* I save my changes
    #Then the history should be "(none)"

  # These are difficult to test, since it's not possible to type a {
  # because that triggers the reference editor.
  # The error could be caused by other actions, like pasting, though

  #Scenario: Editing a history item with a reference in it
    #Given there is a reference for "Bolton, 2005"
    #When I go to the catalog
    #Then I should not see "Bolton, 2005"
    #When I click the edit icon
    #* I edit the history item to include that reference
    #* I save my changes
    #Then the history should be "Bolton, 2005."

  #Scenario: Editing a history item and including an unparseable or unknown reference id
    #When I go to the catalog
    #* I click the edit icon
    #* I edit the history item to "{123}"
    #* I press "Save"
    #Then I should see an error message about the unfound reference

  #Scenario: Changing a history item, but cancelling
    #When I go to the catalog
    #Then the history should be "Taxonomic history."
    #* I click the edit icon
    #* I edit the history item to "(none)"
    #* I press "Cancel"
    #Then the history should be "Taxonomic history."

  #Scenario: Having an error with the item (because it's blank)
    #When I go to the catalog
    #* I click the edit icon
    #* I edit the history item to ""
    #* I save my changes
    #Then I should see "Taxt can't be blank"

  #Scenario: Having an error then cancelling
    #When I go to the catalog
    #* I click the edit icon
    #* I edit the history item to ""
    #* I save my changes
    #Then I should see "Taxt can't be blank"
    #* I press "Cancel"
    #Then the history should be "Taxonomic history."
