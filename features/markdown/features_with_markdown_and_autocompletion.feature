Feature: Features with markdown and autocompletion
  Background:
    Given I log in as a catalog editor

  Scenario: Site notices
    When I go to the site notices page
    And I follow "New"
    Then there should be a textarea with markdown and autocompletion

  Scenario: Issues
    When I go to the new issue page
    Then there should be a textarea with markdown and autocompletion

  Scenario: Comments
    Given a visitor has submitted a feedback
    And I go to the most recent feedback item

    Then there should be a textarea with markdown and autocompletion
