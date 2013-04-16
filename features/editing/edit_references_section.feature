@javascript
Feature: Editing references sections
  As an editor of AntCat
  I want to change previously entered taxonomic history items
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    Given the Formicidae family exists
    And there is a subfamily "Dolichoderinae" with a reference section "Original reference"
    And I log in

  Scenario: Editing a reference section
    When I go to the edit page for "Dolichoderinae"
    Then the reference section should be "Original reference"
    When I click the reference section
    And I fill in the references field with "(none)"
    And I save the reference section
    Then I should not see "Original reference"
    And the reference section should be "(none)"

  Scenario: Editing a reference section, but cancelling
    When I go to the edit page for "Dolichoderinae"
    And I click the reference section
    And I fill in the references field with "(none)"
    And I cancel the reference section's changes
    Then the reference section should be "Original reference"

  #Scenario: Editing an item so it's blank
    #When I go to the edit page for "Dolichoderinae"
    #And I click the history item
    #And I edit the history item to ""
    #And I save the history item
    #Then I should see "Taxt can't be blank"

  ## Pressing Insert Name seems to submit or cancel whole form (only in test)
  ##Scenario: Editing, cancelling, then editing again
    ##When I go to the edit page for "Dolichoderinae"
    ##And I click the history item
    ##And I press "Cancel"
    ##And I click the history item
    ##And I press that history item's "Insert Name" button
    ##Then I should see the name popup

  #Scenario: Adding a history item
    #When I go to the edit page for "Atta"
    #Then the history should be empty
    #When I click the "Add History" button
    #Then I should not see the "Delete" button for the history item
    #And I edit the history item to "Abc"
    #And I save the history item
    #Then the history should be "Abc"

  #Scenario: Adding a history item with blank taxt
    #When I go to the edit page for "Atta"
    #Then the history should be empty
    #When I click the "Add History" button
    #And I save the history item
    #Then I should see "Taxt can't be blank"

  #Scenario: Adding a history item, but cancelling
    #When I go to the edit page for "Atta"
    #Then the history should be empty
    #When I click the "Add History" button
    #And I cancel the history item's changes
    #Then the history should be empty

  Scenario: Deleting a reference section
    When I go to the edit page for "Dolichoderinae"
    And I click the first reference section
    Then I should see the "Delete" button for the reference section
    Given I will confirm on the next step
    When I delete the reference section
    And the reference section should be empty
