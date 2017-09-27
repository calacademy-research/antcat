Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

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
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a genus "Eciton"

    When I go to the edit page for "Eciton"
    And I click the authorship field
    And in the reference picker, I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    Then the authorship field should contain "Fisher 2004. Ants. Psyche 3:3"

    When I fill in the authorship notes with "Authorship notes"
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
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

  Scenario: Changing verbatim type locality
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I fill in "taxon_verbatim_type_locality" with "San Pedro, CA"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see "San Pedro"

    When I follow "Edit"
    Then I should see "San Pedro"

  Scenario: Don't see verbatim type locality field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta"
    Then I should not see "Verbatim type locality"

    When I go to the edit page for "Atta major"
    Then I should see "Verbatim type locality"

  Scenario: Changing type specimen repository
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I fill in "taxon_type_specimen_repository" with "CZN"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see "CZN"

    When I follow "Edit"
    Then the "taxon_type_specimen_repository" field should contain "CZN"

  Scenario: Don't see verbatim type locality field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta"
    Then I should not see "Type specimen repository"

    When I go to the edit page for "Atta major"
    Then I should see "Type specimen repository"

  Scenario: Changing type specimen URL
    Given a species exists with a name of "major" and a genus of "Atta"
    And that URL "www.antweb.com" exists

    When I go to the edit page for "Atta major"
    And I fill in "taxon_type_specimen_url" with "www.antweb.com/"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see a link "www.antweb.com/"

    When I follow "Edit"
    Then the "taxon_type_specimen_url" field should contain "www.antweb.com/"

  Scenario: Changing biogeographic region
    Given a species exists with a name of "major" and a genus of "Atta"

    When I go to the edit page for "Atta major"
    And I select "Malagasy" from "taxon_biogeographic_region"
    And I save the taxon form
    Then I should be on the catalog page for "Atta major"
    And I should see "Malagasy"

    When I follow "Edit"
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

    When I follow "Edit"
    And I select "" from "taxon_biogeographic_region"
    And I save the taxon form
    Then I should not see "Malagasy"
