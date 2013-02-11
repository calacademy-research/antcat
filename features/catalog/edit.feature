@javascript @editing
Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Scenario: Editing a genus
    Given there is a genus called "Calyptites"
    When I go to the edit page for "Calyptites"
    And I set the genus name to "Atta"
    And I save the form
    Then I should see "Atta" in the header

  Scenario: Trying to enter a blank name
    Given there is a genus called "Calyptites"
    When I go to the edit page for "Calyptites"
    And I set the genus name to ""
    And I save the form
    Then I should see "Name can't be blank"

  Scenario: Trying to set a genus's name to an existing one
    Given there is a genus called "Calyptites"
    And there is a genus called "Atta"
    When I go to the edit page for "Calyptites"
    And I set the genus name to "Calyptites"
    And I save the form
    #Then I should see "Do you want to create a homonym?"
