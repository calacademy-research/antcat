@javascript
Feature: Editing a history item
  As an editor of AntCat
  I want to change previously entered taxonomic history items
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    Given the Formicidae family exists

  Scenario: Editing a history item
    When I go to the catalog
    Then the history should be "Taxonomic history"
    When I click the edit icon
    When I edit the history item to "(none)"
    And I save my changes
    Then the history should be "(none)"
