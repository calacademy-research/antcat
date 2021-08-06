Feature: Editing a history item
  Background:
    Given I log in as a catalog editor named "Archibald"

  @skip_ci @javascript
  Scenario: Adding a relational history item
    Given there is a genus protonym "Atta"
    And this reference exists
      | author   | year |
      | Batiatus | 2004 |

    When I go to the protonym page for "Atta"
    Then the history should be empty

    When I click on the add history item button
    And I select "Form descriptions (additional)" from "history_item_type"
    And I fill in "history_item_text_value" with "w.q."
    And I fill in "history_item_pages" with "123"
    And I pick "Batiatus, 2004" from the "#history_item_reference_id" reference picker
    And I press "Save"
    Then I should see "Successfully added history item"
    And I should see "Batiatus, 2004: 123 (w.q.)"

  Scenario: Adding a relational history item with errors
    Given there is a genus protonym "Atta"

    When I go to the protonym page for "Atta"
    Then the history should be empty

    When I click on the add history item button
    And I select "Form descriptions (additional)" from "history_item_type"
    And I fill in "taxt" with "Pizza"

    And I press "Save"
    Then I should see "Taxt must be blank"
    And I should see "Text value can't be blank"
    And I should see "Reference can't be blank"
    And I should see "Pages can't be blank"

  @javascript
   Scenario: Editing a history item (via history item page)
    Given Batiatus, 2004a: "77-78" has described the forms "q." for the protonym "Formica fusca"

    When I go to the protonym page for "Formica fusca"
    Then I should see "Batiatus, 2004a: 77-78 (q.)"

    When I go to the page of the most recent history item
    And I follow "Edit"
    And I fill in "history_item_text_value" with "w."
    And I fill in "history_item_pages" with "99"
    And I press "Save"
    Then I should see "Successfully updated history item"
    And I should see "Batiatus, 2004a: 99 (w.)"

  @javascript
   Scenario: Editing a history item (Quick edit)
    Given Batiatus, 2004a: "77-78" has described the forms "q." for the protonym "Formica fusca"

    When I go to the protonym page for "Formica fusca"
    Then I should see "Batiatus, 2004a: 77-78 (q.)"

    When I click on the edit history item button
    And I fill in "text_value" with "w."
    And I fill in "pages" with "99"
    And I click on the save history item button
    And I reload the page
    Then I should see "Batiatus, 2004a: 99 (w.)"
