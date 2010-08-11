Feature: Add reference
  As Phil Ward
  I want to add new references
  So that my bibliography continues to be useful

  Scenario: Add a reference

  Scenario: Cancel adding a reference
    When I go to the main page
      And I follow "New Reference"
      And I fill in "Year" with "1758"
      And I press "Cancel"
    Then I should be on the main page
      And I should not see "1758"    
