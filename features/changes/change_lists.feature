Feature: Changes Lists
  Background:
    Given I log in

  Scenario: No changes
    When I go to the changes page
    And I follow "Unreviewed changes"
    Then I should see "There are no unreviewed changes."
