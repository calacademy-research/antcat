Feature: Force-changing parent
  Background:
    Given I log in as a superadmin named "Archibald"

  @javascript
  Scenario: Changing a genus's subfamily (with feed)
    Given the Formicidae family exists
    And there is a subfamily "Attininae"
    And there is a genus "Atta" in the subfamily "Attininae"
    And there is a subfamily "Ecitoninae"

    When I go to the catalog page for "Atta"
    And I follow "Force parent change"
    And I set the new parent field to "Ecitoninae"
    And I press "Change parent"
    Then I should be on the catalog page for "Atta"
    And the "subfamily" of "Atta" should be "Ecitoninae"

    When I go to the activity feed
    Then I should see "Archibald force-changed the parent of Atta" within the activity feed
