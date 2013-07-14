@javascript
Feature: Paper trail

  Scenario: Going to the page without crashing
    When I go to the paper trail page
    Then I should see "Changes feed"
