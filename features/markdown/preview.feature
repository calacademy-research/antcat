@javascript
Feature: Preview markdown
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Previewing references markdown
    Given there is a Giovanni reference
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "See: %reference7777"
    And I press "Rerender preview"
    Then I should see "See: Giovanni, 1809"

  @skip
  Scenario: Previewing references markdown (click to expand)
    Given there is a Giovanni reference
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "See: %reference7777"
    And I press "Rerender preview"
    And I should not see "Giovanni's Favorite Ants"
    When I follow "Giovanni, 1809"
    Then I should see "Giovanni's Favorite Ants"

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

  # Testing multiple at the same time because JS tests are painfully slow.
  Scenario: Previewing journal, issue and feedback markdown
    Given there is a closed issue "Cleanup synonyms"
    And a visitor has submitted a feedback
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with markdown links for the above
    And I press "Rerender preview"
    Then I should see "(Cleanup synonyms)"
    And I should see "feedback #"
