Feature: Delete reference
  Background:
    Given I am logged in as a catalog editor
    And there is a reference

  Scenario: Delete a reference
    When I go to the page of the most recent reference
    And I follow "Delete"
    Then I should see "Reference was successfully deleted"

  Scenario: Try to delete a reference when there are references to it
    Given there is a taxon with that reference as its protonym's reference

    When I go to the page of the most recent reference
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "This reference can't be deleted, as there are other references to it."
    And I should be on the page of the most recent reference
