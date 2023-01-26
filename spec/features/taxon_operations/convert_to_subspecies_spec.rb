Feature: Converting a species to a subspecies
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Converting a species to a subspecies (with feed)
    Given there is a species "Camponotus dallatorei" in the genus "Camponotus"
    And there is a species "Camponotus alii" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus dallatorei"
    And I follow "Convert to subspecies"
    Then I should see "Convert species"
    And I should see "to be a subspecies of"

    When I pick "Camponotus alii" from the "#new_species_id" taxon picker
    And I press "Convert"
    Then I should be on the catalog page for "Camponotus alii dallatorei"
    And "Camponotus alii dallatorei" should be of the rank of "subspecies"

    When I go to the activity feed
    Then I should see "Archibald converted the species Camponotus dallatorei to a subspecies (now Camponotus alii dallatorei)" within the activity feed

  Scenario: Converting a species to a subspecies when it already exists
    Given there is a species "Camponotus alii" in the genus "Camponotus"
    And there is a subspecies "Camponotus alii dallatorei" in the species "Camponotus alii"
    And there is a species "Camponotus dallatorei" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus dallatorei"
    And I follow "Convert to subspecies"
    And I pick "Camponotus alii" from the "#new_species_id" taxon picker
    And I press "Convert"
    Then I should see "This name is in use by another taxon"
