@javascript
Feature: Editing a taxon's name, protonym name, or type name
  Background:
    Given I am logged in as a catalog editor

  Scenario: Changing the type name
    Given there is a genus "Atta" with type name "Atta major"
    And there is a species "Atta minor"

    When I go to the edit page for "Atta"
    And I set the type name to "Atta minor"
    And I press "Save"
    Then I should see "Atta minor" in the headline

  Scenario: Changing current valid name
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Atta major"
    And I set the current valid taxon name to "Eciton minor"
    And I press "Save"
    And I follow "Edit"
    Then the current valid taxon name should be "Eciton minor"

    When I press "Save"
    Then I should see "synonym of current valid taxon Eciton minor"
