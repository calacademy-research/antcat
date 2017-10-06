@javascript
Feature: Editing references sections
  As an editor of AntCat
  I want to change previously entered taxonomic reference sections
  So that information is kept accurate and mistakes are fixed
  So people use AntCat

  Background:
    Given I am logged in

  @feed
  Scenario: Editing a reference section (with edit summary)
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    Then the reference section should be "Original reference"

    When I click the reference section
    And I fill in the references field with "(none)"
    And I fill in "reference_section_edit_summary" with "fix typo"
    And I save the reference section
    And I wait
    Then I should not see "Original reference"
    And the reference section should be "(none)"

    When I go to the activity feed
    And I should see the edit summary "fix typo"

  Scenario: Editing a reference section, but cancelling
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    And I click the reference section
    And I fill in the references field with "(none)"
    And I cancel the reference section's changes
    Then the reference section should be "Original reference"

  @feed
  Scenario: Adding a reference section (with edit summary)
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    Then the reference section should be empty

    When I click the "Add" reference section button
    Then I should not see the "Delete" button for the reference section

    When I fill in the references field with "New reference"
    And I fill in "reference_section_edit_summary" with "added new stuff"
    And I save the reference section
    And I wait
    Then the reference section should be "New reference"

    When I go to the activity feed
    And I should see the edit summary "added new stuff"

  Scenario: Adding a reference section, but cancelling
    Given there is a genus "Atta"

    When I go to the edit page for "Atta"
    And I click the "Add" reference section button
    And I cancel the reference section's changes
    Then the reference section should be empty

  Scenario: Deleting a reference section
    Given there is a subfamily "Dolichoderinae" with a reference section "Original reference"

    When I go to the edit page for "Dolichoderinae"
    And I click the reference section
    Then I should see the "Delete" button for the reference section

    Given I will confirm on the next step
    When I delete the reference section
    Then the reference section should be empty
