Feature: Changes Lists
  Background:
    Given I am logged in

  Scenario: No changes
    When I go to the changes page
    And I follow "Unreviewed Changes"
    Then I should see "There are no unreviewed changes."
