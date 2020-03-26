@javascript
Feature: Markdown autocompletion
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search
  Scenario: References markdown autocompletion
    Given these references exist
      | author       | title                    | citation_year |
      | Giovanni, S. | Giovanni's Favorite Ants | 1810          |
      | Joffre, J.   | Joffre's Favorite Ants   | 1810          |
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "{rfav"
    Then I should see "Giovanni's Favorite Ants"
    And I should see "Joffre's Favorite Ants"

    When I clear the markdown textarea
    Then I should not see "Favorite Ants"

    When I fill in "issue_description" with "{rjof"
    And I click the suggestion containing "Joffre's Favorite Ants"
    Then the markdown textarea should contain a markdown link to "Joffre, 1810"

  Scenario: Taxa markdown autocompletion
    Given there is a genus "Eciton"
    And there is a genus "Atta"
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "{tec"
    Then I should see "Eciton"

    When I click the suggestion containing "Eciton"
    Then the markdown textarea should contain a markdown link to Eciton

  Scenario: User markdown autocompletion
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "@arch"
    And I click the suggestion containing "Archibald"
    Then the markdown textarea should contain a markdown link to Archibald's user page
