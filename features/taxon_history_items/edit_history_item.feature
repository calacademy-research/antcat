@javascript
Feature: Editing a history item
  As an editor of AntCat
  I want to change previously entered taxonomic history items
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    And I am logged in

  @feed
  Scenario: Editing a history item
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    Then the history should be "Taxonomic history"

    When I click on the edit taxon history item button
    And I fill in "taxt" with "(none)"
    And I fill in "edit_summary" with "fix typo" within ".history_items"
    And I save the taxon history item
    Then I should not see "Taxonomic history"
    And the history should be "(none)"

    When I click on the edit taxon history item button
    Then the history item field should be "(none)"

    When I go to the activity feed
    Then I should see the edit summary "fix typo"

  Scenario: Editing a history item, but cancelling
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    And I click on the edit taxon history item button
    And I fill in "taxt" with "(none)"
    And I click on the cancel taxon history item button
    Then the history should be "Taxonomic history"

    When I click on the edit taxon history item button
    Then the history item field should be "Taxonomic history"

  Scenario: Editing an item so it's blank
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    And I click on the edit taxon history item button
    And I fill in "taxt" with ""
    And I save the taxon history item
    Then I should see an alert "Taxt can't be blank"

  @feed
  Scenario: Adding a history item (with edit summary)
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the add taxon history item button
    And I fill in "taxt" with "Abc"
    And I fill in "edit_summary" with "added new stuff"
    And I press "Save"
    Then the history should be "Abc"

    When I go to the activity feed
    Then I should see the edit summary "added new stuff"

  Scenario: Adding a history item with blank taxt
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the add taxon history item button
    And I press "Save"
    Then I should see "Taxt can't be blank"

  Scenario: Deleting a history item
    Given there is a genus "Eciton" with taxonomic history "Eciton history"

    When I go to the edit page for "Eciton"
    Then I should see "Eciton history"

    When I click on the edit taxon history item button
    And I will confirm on the next step
    And I delete the taxon history item
    Then I should be on the edit page for "Eciton"

    When I refresh the page (JavaScript)
    Then the history should be empty

  Scenario: Seeing the markdown preview (and cancelling)
    Given there is a Giovanni reference
    And there is a genus "Eciton" with taxonomic history "Eciton history, {ref 7777}"

    When I go to the edit page for "Eciton"
    Then I should see "Eciton history, Giovanni, 1809"
    And the history item field should not be visible

    When I click on the edit taxon history item button
    Then I should still see "Eciton history, Giovanni, 1809"
    And the history item field should be visible

    When I fill in "taxt" with "Lasius history, {ref 7777}"
    And I press all "Rerender preview"
    Then I should see "Lasius history, Giovanni, 1809"

    When I click on the cancel taxon history item button
    Then I should see "Eciton history, Giovanni, 1809"
    And the history item field should not be visible
