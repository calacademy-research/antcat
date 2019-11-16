Feature: Elevating subspecies to species
  Background:
    Given I log in as a catalog editor named "Archibald"
    And there is a species "Solenopsis speccus" in the genus "Solenopsis"
    And there is a subspecies "Solenopsis speccus subbus" in the species "Solenopsis speccus"

  Scenario: Elevating subspecies to species (with feed)
    When I go to the catalog page for "Solenopsis speccus subbus"
    And I will confirm on the next step
    And I follow "Elevate to species"
    Then I should see "Subspecies was successfully elevated to a species."
    And "Solenopsis subbus" should be of the rank of "species"

    When I go to the activity feed
    Then I should see "Archibald elevated the subspecies Solenopsis speccus subbus to the rank of species (now Solenopsis subbus)" within the feed

  Scenario: Elevating to species when the species name exists
    Given there is a species "Solenopsis subbus"

    When I go to the catalog page for "Solenopsis speccus subbus"
    And I will confirm on the next step
    And I follow "Elevate to species"
    Then I should see "This name is in use by another taxon"
