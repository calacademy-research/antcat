@javascript
Feature: Editing a taxon's homonym replaced by
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given there is a genus "Atta"
    And I am logged in

  Scenario: Changing the homonym replaced by name
    Given there is a genus "Eciton"

    When I go to the edit page for "Atta"
    And I set the status to "homonym"
    And I set the homonym replaced by name to "Eciton"
    And I save my changes
    Then I should see "Eciton" in the header

  Scenario: Setting the homonym replaced by name doesn't affect status
    Given there is a genus "Eciton"

    When I go to the edit page for "Atta"
    Then the status should be "valid"

    When I set the status to "homonym"
    And I set the homonym replaced by name to "Eciton"
    And I set the status to "valid"
    And I save my changes
    And I go to the edit page for "Atta"
    Then the status should be "valid"

  Scenario: The homonym replaced by can be cleared
    Given there is a genus "Eciton"

    When I go to the edit page for "Atta"
    And I set the status to "homonym"
    Then the homonym replaced by name should be "(none)"

    And I set the homonym replaced by name to "Eciton"
    And I save my changes
    And I go to the edit page for "Atta"
    And I set the homonym replaced by name to ""
    And I save my changes
    And I go to the edit page for "Atta"
    Then the homonym replaced by name should be "(none)"
