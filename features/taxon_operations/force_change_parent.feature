@javascript
Feature: Force-changing parent
  Background:
    Given I log in as a superadmin named "Archibald"

  Scenario: Forcing a parent change (and see it in the activity feed)
    Given activity tracking is disabled
      And a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"
      And there is a subfamily "Formicinae"
    And activity tracking is enabled

    When I go to the catalog page for "Atta"
    And I follow "Force parent change"
    And I set the new parent field to "Formicinae"
    And I press "Change parent"
    Then I should be on the catalog page for "Atta"
    And the "subfamily" of "Atta" should be "Formicinae"

    When I go to the activity feed
    Then I should see "Archibald force-changed the parent of Atta" and no other feed items
