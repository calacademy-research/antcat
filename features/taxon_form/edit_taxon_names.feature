@javascript
Feature: Editing a taxon's name, protonym name, or type name
  Background:
    Given I am logged in as a catalog editor

  Scenario: Editing a family's name
    Given the Formicidae family exists
    And there is a subfamily "Formicinae"

    When I go to the edit page for "Formicinae"
    And I click the name field
    And I set the name to "Wildencinae"
    And I press "OK"
    And I press "Save"
    Then I should see "Wildencinae" in the header

  Scenario: Setting a genus's name to an existing one
    Given there is a genus "Calyptites"
    And there is a genus "Atta"

    When I go to the edit page for "Atta"
    And I click the name field
    And I set the name to "Calyptites"
    And I press "OK"
    Then I should see "This name is in use by another taxon. To create a homonym, click"

    When I press "Save homonym"
    Then I should not see "This name is in use by another taxon. To create a homonym, click"

  Scenario: Changing the protonym name
    Given there is a genus "Atta" with protonym name "Atta"
    And there is a genus "Eciton"

    When I go to the edit page for "Atta"
    And I click the protonym name field
    And I set the protonym name to "Eciton"
    And I press "OK"
    And I press "Save"
    Then I should see "Eciton" in the headline

  Scenario: Changing the type name
    Given there is a genus "Atta" with type name "Atta major"
    And there is a species "Atta major"
    And there is a species "Atta minor"

    When I go to the edit page for "Atta"
    And I click the type name field
    And I set the type name to "Atta minor"
    And I press "OK"
    And I press "Save"
    Then I should see "Atta minor" in the headline

  Scenario: Clearing the type name
    Given there is a genus "Atta" with type name "Atta major"

    When I go to the catalog page for "Atta"
    Then I should not see "Atta major" in the headline

    When I follow "Edit"
    And I click the type name field
    And I set the type name to ""
    And I press "OK"
    And I press "Save"
    Then I should not see "Atta major" in the headline

  Scenario: Changing current valid name
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Atta major"
    And I set the current valid taxon name to "Eciton minor"
    And I press "Save"
    And I follow "Edit"
    Then the current valid taxon name should be "Eciton minor"

    When I press "Save"
    Then I should see "synonym of current valid taxon Eciton minor"
