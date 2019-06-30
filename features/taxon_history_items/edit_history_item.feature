Feature: Editing a history item
  Background:
    Given I log in as a catalog editor named "Archibald"

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
    Then I should see "Archibald added the history item #" and no other feed items
    And I should see "belonging to Atta"
    And I should see the edit summary "added new stuff"

  @javascript
  Scenario: Adding a history item with blank taxt
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the history should be empty

    When I click the add taxon history item button
    And I press "Save"
    Then I should see "Taxt can't be blank"

  @javascript
  Scenario: Editing a history item (with feed)
    Given the Formicidae family exists
    And Formicidae has a history item "Formicidae as family"

    When I go to the edit page for "Formicidae"
    Then the history should be "Formicidae as family"

    When I click on the edit taxon history item button
    And I fill in "taxt" with "(none)"
    And I fill in "edit_summary" with "fix typo" within ".history-items"
    And I save the taxon history item
    Then I should not see "Formicidae as family"
    And the history should be "(none)"

    When I click on the edit taxon history item button
    Then the history item field should be "(none)"

    When I go to the activity feed
    Then I should see "Archibald edited the history item #" and no other feed items
    And I should see "belonging to Formicidae"
    And I should see the edit summary "fix typo"

  Scenario: Editing a history item (without JavaScript)
    Given the Formicidae family exists
    And Formicidae has a history item "Formicidae as family"

    When I go to the page of the most recent history item
    And I follow "Edit"
    Then I should see "Formicidae as family"

    When I fill in "taxt" with "history item content"
    And I press "Save"
    Then I should see "Successfully updated history item."
    And I should see "history item content"

  @javascript
  Scenario: Editing a history item, but cancelling
    Given the Formicidae family exists
    And Formicidae has a history item "Formicidae as family"

    When I go to the edit page for "Formicidae"
    And I click on the edit taxon history item button
    And I fill in "taxt" with "(none)"
    And I click on the cancel taxon history item button
    Then the history should be "Formicidae as family"

    When I click on the edit taxon history item button
    Then the history item field should be "Formicidae as family"

  @javascript
  Scenario: Editing an item so it's blank
    Given the Formicidae family exists
    And Formicidae has a history item "Formicidae as family"

    When I go to the edit page for "Formicidae"
    And I click on the edit taxon history item button
    And I fill in "taxt" with ""
    And I save the taxon history item
    Then I should see an alert "Taxt can't be blank"

  @javascript
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

    When I go to the activity feed
    Then I should see "Archibald deleted the history item #" and no other feed items
    And I should see "belonging to Eciton"

  @javascript
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
