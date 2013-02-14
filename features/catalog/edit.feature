@javascript @editing
Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Scenario: Editing a genus
    Given there is a genus called "Calyptites"
    When I go to the edit page for "Calyptites"
    And I set the name to "Atta"
    And I save the form
    Then I should see "Atta" in the header

  Scenario: Editing a family
    Given there is a family called "Formicidae"
    When I go to the edit page for "Formicidae"
    And I set the name to "Formica"
    And I save the form
    Then I should see "Formica" in the header

  Scenario: Trying to enter a blank name
    Given there is a genus called "Calyptites"
    When I go to the edit page for "Calyptites"
    And I set the genus name to ""
    And I save the form
    Then I should see "Name can't be blank"

  Scenario: Setting a genus's name to an existing one
    Given there is a genus called "Calyptites"
    And there is a genus called "Atta"
    When I go to the edit page for "Atta"
    And I set the genus name to "Calyptites"
    And I save the form
    Then I should see "This name is in use by another taxon"
    When I press "Save Homonym"
    Then there should be two genera with the name "Calyptites"

  Scenario: Leaving a genus name alone when there are already two homonyms
    Given there are two genera called "Calyptites"
    When I go to the edit page for "Calyptites"
    And I save the form
    Then I should not see "This name is in use by another taxon"
    Then I should see "Calyptites" in the header
