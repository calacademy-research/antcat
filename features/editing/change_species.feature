@javascript
Feature: Changing species
  As an editor of AntCat
  I want to change a subspecies's species
  So that information is kept accurate
  So people use AntCat

  Scenario: Changing a subspecies's species
    Given I am logged in
    And there is a species "Atta major" with genus "Atta"
    And there is a species "Eciton major" with genus "Eciton"
    And there is a subspecies "Atta major minor" which is a subspecies of "Atta major"
    When I go to the edit page for "Atta major minor"
    And I click the parent name field
    And I set the parent name to "Eciton major"
    And I press "OK"
    When I save my changes
    And I wait for a bit
    Then I should be on the catalog page for "Eciton major minor"

  Scenario: Parent field not visible for the family
    Given there is a family "Formicidae"
    And I log in
    When I go to the edit page for "Formicidae"
    Then I should not see the parent name field
