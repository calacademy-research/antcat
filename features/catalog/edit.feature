@javascript @editing
Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Scenario: Editing a genus
    Given there is a genus called "Calyptites"
    When I go to the edit page for the genus
    And I set the genus name to "Atta"
    And I save the form
    Then I should see "Atta" in the header

  Scenario: Trying to add a genus with a blank name
    Given there is a genus called "Calyptites"
    When I go to the edit page for the genus
    And I set the genus name to ""
    And I save the form
    Then I should see "Name can't be blank"
