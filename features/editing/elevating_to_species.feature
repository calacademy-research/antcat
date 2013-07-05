@javascript
Feature: Elevating subspecies to species
  As an editor of AntCat
  I want to make a subspecies a species
  So the data is correct

  Scenario: Elevating subspecies to species
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And I am logged in
    When I go to the catalog entry for "Solenopsis speccus subbus"
    And I press "Edit"
    Given I will confirm on the next step
    And I press "Elevate to species"
    Then I should see the catalog entry for "Solenopsis subbus"

  Scenario: Only show button if showing a subspecies
    Given there is a species "Atta"
    And I am logged in
    When I go to the catalog entry for "Atta"
    And I press "Edit"
    Then I should not see "Elevate to species"
