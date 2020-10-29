Feature: Editing a history item
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Adding a history item (with edit summary)
    Given there is a genus protonym "Atta"

    When I go to the protonym page for "Atta"
    Then the history should be empty

    When I click on the add history item button
    And I fill in "taxt" with "Abc"
    And I fill in "edit_summary" with "added new stuff"
    And I press "Save"
    Then the history should be "Abc"

    When I go to the activity feed
    Then I should see "Archibald added the history item #" within the activity feed
    And I should see "belonging to Atta"
    And I should see the edit summary "added new stuff"

  Scenario: Adding a history item with blank taxt
    Given there is a genus protonym "Atta"

    When I go to the protonym page for "Atta"
    Then the history should be empty

    When I click on the add history item button
    And I press "Save"
    Then I should see "Taxt can't be blank"

  @javascript
  Scenario: Editing a history item (with edit summary)
    Given there is a subfamily protonym "Antcatinae" with a history item "Antcatinae as family"

    When I go to the protonym page for "Antcatinae"
    Then the history should be "Antcatinae as family"

    When I click on the edit history item button
    And I fill in "taxt" with "(none)"
    And I fill in "edit_summary" with "fix typo" within "#history-items"
    And I click on the save history item button
    And I reload the page
    Then I should not see "Antcatinae as family"
    And the history should be "(none)"

    When I click on the edit history item button
    Then the history item field should be "(none)"

    When I go to the activity feed
    Then I should see "Archibald edited the history item #" within the activity feed
    And I should see "belonging to Antcatinae"
    And I should see the edit summary "fix typo"

  Scenario: Editing a history item (without JavaScript)
    Given there is a subfamily protonym "Antcatinae" with a history item "Antcatinae as family"

    When I go to the page of the most recent history item
    And I follow "Edit"
    Then I should see "Antcatinae as family"

    When I fill in "taxt" with "history item content"
    And I press "Save"
    Then I should see "Successfully updated history item."
    And I should see "history item content"

  @javascript
  Scenario: Editing a history item, but cancelling
    Given there is a subfamily protonym "Antcatinae" with a history item "Antcatinae as family"

    When I go to the protonym page for "Antcatinae"
    And I click on the edit history item button
    And I fill in "taxt" with "(none)"
    And I click on the cancel history item button
    Then the history should be "Antcatinae as family"

    When I click on the edit history item button
    Then the history item field should be "Antcatinae as family"

  @javascript
  Scenario: Deleting a history item (with feed)
    Given there is a subfamily protonym "Antcatinae" with a history item "Antcatinae as family"

    When I go to the protonym page for "Antcatinae"
    Then I should see "Antcatinae as family"

    When I click on the edit history item button
    And I will confirm on the next step
    And I click on the delete history item button
    Then I should be on the protonym page for "Antcatinae"

    When I reload the page
    Then the history should be empty

    When I go to the activity feed
    Then I should see "Archibald deleted the history item #" within the activity feed
    And I should see "belonging to Antcatinae"

  @javascript
  Scenario: Seeing the markdown preview (and cancelling)
    Given this reference exists
      | author       | year |
      | Giovanni, S. | 1809 |
    And there is a subfamily protonym "Antcatinae" with a history item "Antcatinae as family," and a markdown link to "Giovanni, 1809"

    When I go to the protonym page for "Antcatinae"
    Then I should see "Antcatinae as family, Giovanni, 1809"
    And the history item field should not be visible

    When I click on the edit history item button
    Then I should see "Antcatinae as family, Giovanni, 1809"
    And the history item field should be visible

    When I fill in "taxt" with "Lasius history," and a markdown link to "Giovanni, 1809"
    And I press "Rerender preview"
    Then I should see "Lasius history, Giovanni, 1809"

    When I click on the cancel history item button
    Then I should see "Antcatinae as family, Giovanni, 1809"
    And the history item field should not be visible
