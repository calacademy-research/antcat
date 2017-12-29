@javascript
Feature: Markdown autocompletion
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search
  Scenario: References markdown autocompletion
    Given there is a Giovanni reference
    And there is a reference by Giovanni's brother
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "{rgio"
    Then I should see "Giovanni's Favorite Ants"
    And I should see "Giovanni's Brother's Favorite Ants"

    When I clear the markdown textarea
    Then I should not see "Favorite Ants"

    When I fill in "issue_description" with "{rbro"
    And I click the suggestion containing "Giovanni's Brother's Favorite Ants"
    Then the markdown textarea should contain "{ref 7778}"

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

  # Testing multiple at the same time because JS tests are painfully slow.
  Scenario: Journal, issue and feedback markdown autocompletion
    Given a journal exists with a name of "Ant Science 2000"
    And there is a closed issue "Cleanup synonyms"
    And a visitor has submitted a feedback
    And I am on a page with a textarea with markdown preview and autocompletion

    # Journal
    When I fill in "issue_description" with "%jsci"
    And I click the suggestion containing "Science"
    Then the markdown textarea should contain "%journal"

    # Issue
    When I fill in "issue_description" with "%icle"
    And I click the suggestion containing "Cleanup"
    Then the markdown textarea should contain "%issue"

    # Feedback
    When I fill in "issue_description" with "%f"
    And I click the suggestion containing "open"
    Then the markdown textarea should contain "%feedback"
