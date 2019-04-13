@feed
Feature: Feed (changes)
  @papertrail
  Scenario: Deleted subfamily and undid the change (with edit summary)
    Given I log in as a catalog editor named "Archibald"
    And activity tracking is disabled
      And there is a subfamily "Ancatinae"
      And genus "Atta" exists in that subfamily
    And activity tracking is enabled
    And I log in as a catalog editor named "Joffre"

    When I go to the catalog page for "Atta"
    And I follow "Delete"
    And I go to the changes page
    And I follow "Undo..."
    And I fill in "edit_summary" with "deleted by mistake..."
    And I press "Undo!"
    And I go to the activity feed
    Then I should see "Joffre undid the change"
    And I should see the edit summary "deleted by mistake..."
    And I should see 2 item in the feed
