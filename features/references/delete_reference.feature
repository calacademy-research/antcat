Feature: Delete reference
  As Phil Ward
  I want to delete a reference
  So that I can add one to test, then delete it right away
  Or so I can delete one that turns out to have been a duplicate

  Background:
    Given I am logged in
    And there is a reference

  Scenario: Delete a reference
    When I go to the page for that reference
    And I follow "Delete"
    Then I should see "Reference was successfully destroyed"

  Scenario: Try to delete a reference when there are references to it
    Given there is a taxon with that reference as its protonym's reference

    When I go to the page for that reference
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "This reference can't be deleted, as there are other references to it."
    And I should be on the page for that reference
