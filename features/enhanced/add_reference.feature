Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Scenario: Add a reference when there are no others
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "OK"
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Mark Wilden"
      And "Add reference" should not be visible

  Scenario: Add but cancel a reference when there are no others
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "Cancel"
      And I should not see "Mark Wilden"

  Scenario: Add a reference when there are others
    Given the following entries exist in the bibliography
      |authors   |title         |
      |Ward, P.S.|Annals of Ants|
    When I go to the main page
      Then "Add reference" should not be visible
    When I follow "add"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_authors" with "Mark Wilden"
      And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
      And in the new edit form I press "OK"
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Mark Wilden . Between Pacific Tides"

  Scenario: Adding a reference but then cancelling
    Given the following entries exist in the bibliography
      |authors   |title         |
      |Ward, P.S.|Annals of Ants|
    When I go to the main page
    When I follow "add"
    When in the new edit form I fill in "reference_authors" with "Mark Wilden"
      And in the new edit form I press "Cancel"
    Then there should be just the existing reference
