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
    And I wait for a while
    And I save my changes
    Then I should not see "Taxonomic history"
    Then the history should be "(none)"

  # This doesn't work because of inserting a {
  #Scenario: Editing a history item to include a reference
    #Given there is a reference for "Bolton, 2005"
    #And I go to the edit page for "Formicidae"
    #Then I should not see "Bolton, 2005"
    #When I click the history item
    #And I edit the history item to include that reference
    #And I save my changes
    #Then the history should be "Bolton, 2005."

  Scenario: Editing a history item, but cancelling
    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to "(none)"
    And I press "Cancel"
    Then the history should be "Taxonomic history."

  Scenario: Editing an item so it's blank
    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to ""
    And I save my changes
    Then I should see "Taxt can't be blank"

  # Pressing Insert Name seems to submit or cancel whole form (only in test)
  #Scenario: Editing, cancelling, then editing again
    #When I go to the edit page for "Formicidae"
    #And I click the history item
    #And I press "Cancel"
    #And I click the history item
    #And I click the history item taxt editor field
    #And I press that history item's "Insert Name" button
    #Then I should see the name popup

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
