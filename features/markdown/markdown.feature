Feature: Markdown
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Using markdown
    Given there is an open task "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the task page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "task_description" with "See: %reference7777"
    And I press "Save"
    Then I should see "See: Giovanni, 1809"

  @javascript
  Scenario: See the formatting help
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I follow "Formatting Help"
    Then I should see "AntCat-specific markdown"
