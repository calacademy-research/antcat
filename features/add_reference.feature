Feature: Add reference
  As Phil Ward
  I want to add new references
  So that my bibliography continues to be useful

  Scenario: Edit a reference
    When I go to the main page
      And I follow "New Reference"
    When I fill in "Year" with "1758"
      And I press "Add"
    Then I should be on the page for that reference
      And I should see "1758"
      And I should see "Reference has been added"
