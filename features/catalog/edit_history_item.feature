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
    * I click the edit icon
    * I edit the history item to "(none)"
    * I save my changes
    Then the history should be "(none)"

  Scenario: Editing a history item with a reference in it
    Given there is a reference for "Bolton, 2005"
    When I go to the catalog
    Then I should not see "Bolton, 2005"
    When I click the edit icon
    * I edit the history item to include that reference
    * I save my changes
    Then the history should be "Bolton, 2005."

  Scenario: Editing a history item and including an unparseable or unknown reference id
    When I go to the catalog
    * I click the edit icon
    * I edit the history item to "{123}"
    * I press "Save"
    Then I should see an error message about the unfound reference

  Scenario: Changing a history item, but cancelling
    When I go to the catalog
    Then the history should be "Taxonomic history."
    * I click the edit icon
    * I edit the history item to "(none)"
    * I press "Cancel"
    Then the history should be "Taxonomic history."
