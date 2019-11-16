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

  @skip
  Scenario: Previewing references markdown (click to expand)
    Given this reference exists
      | author       | title                    | citation_year |
      | Giovanni, S. | Giovanni's Favorite Ants | 1809          |
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "See: %reference7777"
    And I press "Rerender preview"
    And I should not see "Giovanni's Favorite Ants"
    When I follow "Giovanni, 1809"
    Then I should see "Giovanni's Favorite Ants"

  Scenario: Previewing converted Bolton keys
    Given there is a history item with Forel 1878 Bolton key I want to convert

    When I go to the page of the most recent history item
    And I follow "Edit"
    Then I should see "Forel, 1878:"
    And I should not see "Forel, 1878b:"

    When I click css "#convert-bolton-keys-button"
    Then I should see "Forel, 1878b:"
    And I should not see "Forel, 1878:"

  Scenario: Previewing taxa markdown
    Given there is a genus "Eciton"
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with "@taxon" followed by Eciton's id
    And I press "Rerender preview"
    Then I should see "Eciton"

  Scenario: Previewing users markdown
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with "@user" followed by my user id
    And I press "Rerender preview"
    Then I should see a link to the user page for "Archibald"
