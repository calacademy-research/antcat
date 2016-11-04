@javascript
Feature: Editing a history item
  As an editor of AntCat
  I want to change previously entered taxonomic history items
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    And I am logged in

  Scenario: Editing a history item
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    Then the history should be "Taxonomic history"

    When I click the history item
    And I edit the history item to "(none)"
    And I save the history item
    Then I should not see "Taxonomic history"
    And I wait for a bit
    And the history should be "(none)"

    When I click the history item
    Then the history item field should be "(none)"

  Scenario: Saving the fields after editing history (regression)
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to "(none)"
    And I save the history item
    And I save my changes
    And I wait for a bit
    Then I should be on the catalog page for "Formicidae"

  # This doesn't work because of inserting a {
  #Scenario: Editing a history item to include a reference
    #Given there is a reference for "Bolton, 2005"

    #When I go to the edit page for "Formicidae"
    #Then I should not see "Bolton, 2005"

    #When I click the history item
    #And I edit the history item to include that reference
    #And I save my changes
    #Then the history should be "Bolton, 2005."

  # This test isn't accurate, as it reports the wrong contents
  # of the history item field
  Scenario: Editing a history item, but cancelling
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to "(none)"
    And I cancel the history item's changes
    Then the history should be "Taxonomic history."

    When I click the history item
    Then the history item field should be "Taxonomic history"

  Scenario: Editing an item so it's blank
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    And I click the history item
    And I edit the history item to ""
    And I save the history item
    Then I should see "Taxt can't be blank"

  # Pressing Insert Name seems to submit or cancel whole form (only in test)
  #Scenario: Editing, cancelling, then editing again
    #When I go to the edit page for "Formicidae"
    #And I click the history item
    #And I press "Cancel"
    #And I click the history item
    #And I press that history item's "Insert Name" button
    #Then I should see the name popup

  Scenario: Adding a history item
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the "Add History" button
    Then I should not see the "Delete" button for the history item
    And I edit the history item to "Abc"
    And I save the history item
    And I wait for a bit
    Then the history should be "Abc"

  Scenario: Adding a history item with blank taxt
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the "Add History" button
    And I save the history item
    Then I should see "Taxt can't be blank"

  Scenario: Adding a history item, but cancelling
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the "Add History" button
    And I cancel the history item's changes
    Then the history should be empty

  Scenario: Deleting a history item
    Given there is a genus "Eciton" with taxonomic history "Eciton history"

    When I go to the edit page for "Eciton"
    Then I should see "Eciton history"

    When I click the history item
    Then I should see the "Delete" button for the history item

    Given I will confirm on the next step
    When I delete the history item
    Then I should be on the edit page for "Eciton"
    And the history should be empty
