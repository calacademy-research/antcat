@javascript
Feature: Markdown autocompletion
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search
  Scenario: References markdown autocompletion
    Given there is a Giovanni reference
    And there is a reference by Giovanni's brother
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "task_description" with "%rgio"
    Then I should see "Giovanni's Favorite Ants"
    And I should see "Giovanni's Brother's Favorite Ants"

    When I fill in "task_description" with "%rsomething_to_clear_the_suggestions"
    And I clear the markdown textarea
    Then I should not see "Favorite Ants"

    When I fill in "task_description" with "%rbro"
    And I click the suggestion containing "Giovanni's Brother's Favorite Ants"
    Then the markdown textarea should contain "%reference7778"

  Scenario: Taxa markdown autocompletion
    Given there is a genus "Eciton"
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "task_description" with "%tec"
    Then I should see "Eciton"

    When I click the suggestion containing "Eciton"
    Then the markdown textarea should contain a markdown link to Eciton

  Scenario: User markdown autocompletion
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "task_description" with "@arch"
    And I click the suggestion containing "Archibald"
    Then the markdown textarea should contain a markdown link to Archibald's user page
