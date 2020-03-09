Feature: Editing references sections
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Adding a reference section (with edit summary)
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the reference section should be empty

    When I click on the add reference section button
    And I fill in "references_taxt" with "New reference"
    And I fill in "edit_summary" with "added new stuff"
    And I press "Save"
    Then the reference section should be "New reference"

    When I go to the activity feed
    Then I should see "Archibald added the reference section #" within the activity feed
    And I should see "belonging to Atta"
    And I should see the edit summary "added new stuff"

  @javascript
  Scenario: Editing a reference section (with edit summary)
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    Then the reference section should be "Original reference"

    When I click on the edit reference section button
    And I fill in "references_taxt" with "(none)"
    And I fill in "edit_summary" with "fix typo" within ".references-section"
    When I click on the save reference section button
    Then I should not see "Original reference"
    And the reference section should be "(none)"

    When I go to the activity feed
    Then I should see "Archibald edited the reference section #" within the activity feed
    And I should see "belonging to Dolichoderinae"
    Then I should see the edit summary "fix typo"

  Scenario: Editing a reference section (without JavaScript)
    Given there is a reference section with the references_taxt "California checklist"

    When I go to the page of the most recent reference section
    Then I should see "California checklist"

    When I follow "Edit"
    And I fill in "references_taxt" with "reference section content"
    And I press "Save"
    Then I should see "Successfully updated reference section."
    And I should see "reference section content"

  @javascript
  Scenario: Editing a reference section, but cancelling
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    And I click on the edit reference section button
    And I fill in "references_taxt" with "(none)"
    And I click on the cancel reference section button
    Then the reference section should be "Original reference"

  @javascript
  Scenario: Deleting a reference section (with feed)
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    And I click on the edit reference section button
    And I will confirm on the next step
    And I click on the delete reference section button
    And WAIT_FOR_JQUERY
    Then the reference section should be empty

    When I go to the activity feed
    Then I should see "Archibald deleted the reference section #" within the activity feed
    And I should see "belonging to Dolichoderinae"
