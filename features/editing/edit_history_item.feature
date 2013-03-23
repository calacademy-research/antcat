@javascript
Feature: Editing a history item
  As an editor of AntCat
  I want to change previously entered taxonomic history items
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    Given the Formicidae family exists
    And a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "Taxonomic history"
    And there is a genus called "Atta"
    And I log in

  Scenario: Editing a history item
    When I go to the edit page for "Formicidae"
    Then the history should be "Taxonomic history"
    When I click the history item
    And I edit the history item to "(none)"
    And I save my changes
    And I wait for a bit
    Then the history should be "(none)"

  Scenario: Changing a history item, but cancelling
    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to "(none)"
    And I press "Cancel"
    Then the history should be "Taxonomic history."

  Scenario: Adding a history item
    When I go to the edit page for "Atta"
    Then the history should be empty
    When I click the "Add History" button
    And I edit the history item to "Abc"
    And I save my changes
    Then the history should be "Abc"

  Scenario: Adding a history item with blank taxt
    When I go to the edit page for "Atta"
    Then the history should be empty
    When I click the "Add History" button
    And I save my changes
    Then I should see "Taxt can't be blank"

  Scenario: Adding a history item, but cancelling
    When I go to the edit page for "Atta"
    Then the history should be empty
    When I click the "Add History" button
    And I press "Cancel"
    Then the history should be empty

  #Scenario: Editing a history item with a reference in it
    #Given there is a reference for "Bolton, 2005"
    #When I go to the catalog
    #Then I should not see "Bolton, 2005"
    #When I click the edit icon
    #And I edit the history item to include that reference
    #* I save my changes
    #Then the history should be "Bolton, 2005."

  #Scenario: Editing a history item and including an unparseable or unknown reference id
    #When I go to the catalog
    #* I click the edit icon
    #* I edit the history item to "{123}"
    #* I press "Save"
    #Then I should see an error message about the unfound reference

  #Scenario: Cancelling, then editing again
    #When I go to the edit page for "Formicidae"
    #And I click the history item
    #And I press "Cancel"
    #And I click the history item
    #And I press that history item's "Insert Name" button
    #Then I should see the name popup

  Scenario: Editing an item so it's blank
    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to ""
    And I save my changes
    Then I should see "Taxt can't be blank"

  Scenario: Adding a history item, with blank taxt

  #Scenario: Having an error then cancelling
    #When I go to the catalog
    #* I click the edit icon
    #* I edit the history item to ""
    #* I save my changes
    #Then I should see "Taxt can't be blank"
    #* I press "Cancel"
    #Then the history should be "Taxonomic history."
