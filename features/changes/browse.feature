Feature: Changes Lists
  Scenario: No changes
    When I go to the changes page
    And I follow "Unreviewed Changes"
    Then I should see "There are no unreviewed changes."
