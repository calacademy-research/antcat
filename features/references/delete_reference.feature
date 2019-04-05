Feature: Delete reference
  Background:
    Given I log in as a catalog editor named "Archibald"

  @feed
  Scenario: Delete a reference
    Given this reference exist
      | author | citation_year |
      | Fisher | 2004          |

    When I go to the page of the most recent reference
    And I follow "Delete"
    Then I should see "Reference was successfully deleted"

    When I go to the activity feed
    Then I should see "Archibald deleted the reference Fisher, 2004" and no other feed items

  Scenario: Try to delete a reference when there are references to it
    Given there is a reference
    And there is a taxon with that reference as its protonym's reference

    When I go to the page of the most recent reference
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "This reference can't be deleted, as there are other references to it."
    And I should be on the page of the most recent reference
