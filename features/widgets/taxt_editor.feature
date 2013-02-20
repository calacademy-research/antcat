@javascript
Feature: Taxt editor

  Scenario: Bringing up the reference popup
    When I go to the taxt editor test page
    And I press "Insert Reference"
    Then I should see the reference popup

  Scenario: Bringing up the name popup
    When I go to the taxt editor test page
    And I press "Insert Taxon"
    Then I should see the name popup
    And I should not see the reference popup
