Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Scenario: Add a reference when there are no others
    When I go to the main page
      And I follow "Add reference"
      Then I should see an edit form
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "OK"
    Then I should be on the main page
      And I should not see an edit form
      And I should see "Mark Wilden"

  Scenario: Adding a reference but then cancelling
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "Cancel"
    Then there should not be any references
