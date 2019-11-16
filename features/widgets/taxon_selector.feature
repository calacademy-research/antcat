@javascript
Feature: Taxon selector
  Background:
    Given I log in as a catalog editor
    And there is a genus "Atta"
    And there is a genus "Eciton"

  Scenario: Using the selector to set a taxon field
    When I go to the edit page for "Atta"
    And I select "homonym" from "taxon_status"
    And I set the homonym replaced by name to "Eciton"
    Then I should see "Eciton"

    When I press "Save"
    Then I should see "Eciton" within the header

  Scenario: Clearing a taxon field
    When I go to the edit page for "Atta"
    And I select "homonym" from "taxon_status"
    Then the homonym replaced by name should be "(none)"

    When I set the homonym replaced by name to "Eciton"
    And I press "Save"
    And I go to the edit page for "Atta"
    Then the homonym replaced by name should be "Eciton"

    When I select "valid" from "taxon_status"
    And I set the homonym replaced by name to ""
    And I press "Save"
    And I go to the edit page for "Atta"
    Then the homonym replaced by name should be "(none)"
