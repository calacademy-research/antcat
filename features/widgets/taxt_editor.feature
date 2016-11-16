@javascript
Feature: Taxt editor
  Background:
    Given I go to the taxt editor test page

  Scenario: Bringing up the reference popup
    Given I hack the taxt editor in test env

    When I press "Insert Reference"
    Then I should see the reference popup

  Scenario: Bringing up the name popup
    When I press "Insert Name"
    Then I should see the name popup
    And I should not see the reference popup
