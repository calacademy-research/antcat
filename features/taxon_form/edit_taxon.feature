Feature: Editing a taxon
  Background:
    Given I am logged in

  Scenario: Editing a species
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header

    When I go to the edit page for "Atta major"
    And I save the taxon form
    Then I should see "Atta major" in the header

  Scenario: Cancelling
    Given there is a genus "Calyptites"

    When I go to the edit page for "Calyptites"
    And I select "subfamily" from "taxon_incertae_sedis_in"
    And I follow "Cancel"
    Then I should not see "incertae sedis" in the header

  @search @javascript
  Scenario: Changing the authorship
    Given this reference exists
      | author | citation   | title | citation_year |
      | Fisher | Psyche 3:3 | Ants  | 2004          |
    And there is a genus "Eciton"

    When I go to the edit page for "Eciton"
    And I set the authorship to the first search results of "Fisher (2004)"
    Then the authorship should contain the reference "Fisher, 2004"

    When I fill in the authorship notes with "Authorship notes"
    And I fill in "taxon_type_taxt" with "Notes"
    And I press "Save"
    Then the taxon mouseover should contain "Fisher 2004. Ants. Psyche 3:3"
    And I should see "Authorship notes" in the headline

  Scenario: Changing incertae sedis
    Given there is a genus "Atta" that is incertae sedis in the subfamily

    When  I go to the catalog page for "Atta"
    Then I should see "incertae sedis in subfamily"

    When I go to the edit page for "Atta"
    And I select "(none)" from "taxon_incertae_sedis_in"
    And I save the taxon form
    Then I should be on the catalog page for "Atta"
    And I should not see "incertae sedis in subfamily"

  Scenario: Changing gender of genus-group name
    Given there is a genus "Atta" with "masculine" name

    When I go to the catalog page for "Atta"
    Then I should see "masculine"

    When I go to the edit page for "Atta"
    And I set the name gender to "neuter"
    And I save the taxon form
    Then I should be on the catalog page for "Atta"
    And I should see "neuter"

  Scenario: Don't see gender field for species-group names
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    Then I should not see the gender menu

    When I go to the edit page for "Atta"
    Then I should see the gender menu

  Scenario: Changing biogeographic region
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I select "Malagasy" from "taxon_biogeographic_region"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see "Malagasy"

    When I press the edit taxon link
    Then I should see "Malagasy" selected in "taxon_biogeographic_region"

  Scenario: Don't see biogeographic region field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta"
    Then I should not see "Biogeographic region"

    When I go to the edit page for "Atta major"
    Then I should see "Biogeographic region"

  Scenario: Clearing the biogeographic_region
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I select "Malagasy" from "taxon_biogeographic_region"
    And I save the taxon form
    Then I should see "Malagasy"

    When I press the edit taxon link
    And I select "" from "taxon_biogeographic_region"
    And I save the taxon form
    Then I should not see "Malagasy"

  Scenario: Editing type fields
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I fill in "taxon_primary_type_information" with "Madagascar: Prov. Tolliara"
    And I fill in "taxon_secondary_type_information" with "A neotype had also been designated"
    And I fill in "taxon_type_notes" with "Note: Typo in Toliara"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see "Madagascar: Prov. Tolliara"
    And I should see "A neotype had also been designated"
    And I should see "Note: Typo in Toliara"
