@javascript
Feature: Taxt editor
  Scenario: Bringing up the reference popup
    When I go to the taxt editor test page
    And I hack the taxt editor in test env
    And I press "Insert Reference"
    Then I should see the reference popup

  Scenario: Bringing up the name popup
    When I go to the taxt editor test page
    And I press "Insert Name"
    Then I should see the name popup
    And I should not see the reference popup
