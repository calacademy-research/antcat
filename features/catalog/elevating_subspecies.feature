Feature: Elevating subspecies
  As an editor of AntCat
  I want to make a subspecies a species
  So the data is correct

  Scenario: Elevating subspecies
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And I am logged in as an editor and have editing turned on
    When I go to the catalog entry for "Solenopsis speccus subbus"
    And I follow "Edit"
    And I press "Elevate to species"
    Then I should see the catalog entry for "Solenopsis subbus"
    And there should be an editing history record showing that the taxon is "Solenopsis subbus" and the old species was "Solenopsis speccus"

  Scenario: Only show button if showing a subspecies
