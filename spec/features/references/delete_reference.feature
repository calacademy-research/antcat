Feature: Delete reference
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Delete a reference (with feed)
    Given this reference exists
      | author | year |
      | Fisher | 2004 |

    When I go to the page of the most recent reference
    And I follow "Delete"
    Then I should see "Reference was successfully deleted"

    When I go to the activity feed
    Then I should see "Archibald deleted the reference Fisher, 2004" within the activity feed

  Scenario: Try to delete a reference when there are references to it
    Given there is a reference referenced in a history item

    When I go to the page of the oldest reference
    And I will confirm on the next step
    And I follow "Delete"
    Then I should see "Other records refer to this reference, so it can't be deleted."
