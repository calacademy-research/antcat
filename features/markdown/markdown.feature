Feature: Markdown
  Background:
    Given I log in as a catalog editor

  Scenario: Using markdown
    Given there is an open issue "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the issue page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "issue_description" with "See: %reference7777"
    And I press "Save"
    Then I should see "See: Giovanni, 1809"

  @javascript
  Scenario: See formatting help
    Given I am on a page with a textarea with markdown preview and autocompletion
    And I should not see "AntCat-specific markdown"

    When I follow "Formatting Help"
    Then I should see "AntCat-specific markdown"
