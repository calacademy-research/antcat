Feature: Converting a species to a subspecies
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Converting a species to a subspecies (with feed)
    Given there is a species "Camponotus dallatorei" in the genus "Camponotus"
    And there is a species "Camponotus alii" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus dallatorei"
    And I follow "Convert to subspecies"
    Then I should see "Convert species"
    And I should see "to be a subspecies of"

    When I set the new species field to "Camponotus alii"
    And I press "Convert"
    Then I should be on the catalog page for "Camponotus alii dallatorei"
    And "Camponotus alii dallatorei" should be of the rank of "subspecies"

    When I go to the activity feed
    Then I should see "Archibald converted the species Camponotus dallatorei to a subspecies (now Camponotus alii dallatorei)" in the feed

  @javascript
  Scenario: Converting a species to a subspecies when it already exists
    Given there is a subspecies "Camponotus alii dallatorei" in the species "Camponotus alii" in the genus "Camponotus"
    And there is a species "Camponotus dallatorei" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus dallatorei"
    And I follow "Convert to subspecies"
    And I set the new species field to "Camponotus alii"
    And I press "Convert"
    Then I should see "This name is in use by another taxon"

  @javascript
  Scenario: Converting a species to a subspecies when the species has subspecies
    Given there is a species "Camponotus alii"
    And there is a subspecies "Camponotus alii major" in the species "Camponotus alii"

    When I go to the catalog page for "Camponotus alii"
    And I follow "Convert to subspecies"
    And I set the new species field to "Camponotus alii"
    And I press "Convert"
    Then I should see "This species has subspecies of its own"

  Scenario: Leaving the species blank
    Given there is a species "Camponotus dallatorei" in the genus "Camponotus"
    And there is a species "Camponotus alii" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus dallatorei"
    And I follow "Convert to subspecies"
    And I press "Convert"
    Then I should see "Please select a species"
