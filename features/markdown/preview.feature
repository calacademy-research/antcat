@javascript
Feature: Preview markdown
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Previewing references markdown
    Given this reference exists
      | author       | citation_year |
      | Giovanni, S. | 1809          |
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "See:" and a markdown link to "Giovanni, 1809"
    And I press "Rerender preview"
    Then I should see "See: Giovanni, 1809"
