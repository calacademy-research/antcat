@javascript
Feature: Force-changing parent
  Background:
    Given I log in as a superadmin named "Archibald"

  Scenario: Forcing a parent change (and see it in the activity feed)
    Given there is a genus "Atta" in the subfamily "Dolichoderinae"
    And there is a subfamily "Formicinae"

    When I go to the catalog page for "Atta"
    And I follow "Force parent change"
    And I set the new parent field to "Formicinae"
    And I press "Change parent"
    Then I should be on the catalog page for "Atta"
    And the "subfamily" of "Atta" should be "Formicinae"

    When I go to the activity feed
    Then I should see "Archibald force-changed the parent of Atta" and no other feed items

  Scenario: Changing a genus's tribe
    Given there is a genus "Atta" in the subfamily "Dolichoderinae"
    And there is a tribe "Ecitonini"

    When I go to the catalog page for "Atta"
    And I follow "Force parent change"
    And I set the new parent field to "Ecitonini"
    And I press "Change parent"
    Then I should be on the catalog page for "Atta"
    And the "tribe" of "Atta" should be "Ecitonini"

  Scenario: Changing a genus's subfamily
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
