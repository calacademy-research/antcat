@javascript
Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Background:
    Given version tracking is enabled

  Scenario: Editing a family's name
    Given there is a family "Formicidae"
    And I log in
    When I go to the edit page for "Formicidae"
    And I click the name field
    And I set the name to "Wildencidae"
    And I press "OK"
    And I save my changes
    Then I should see "Wildencidae" in the header

  Scenario: Trying to enter a blank name
    Given there is a family "Formicidae"
    And I log in
    When I go to the edit page for "Formicidae"
    And I click the name field
    And I set the name to ""
    And I press "OK"
    Then I should still see the name field

  Scenario: Editing a species
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header
    When I go to the edit page for "Atta major"
    And I save my changes
    And I wait for a bit
    Then I should see "Atta major" in the header

  Scenario: Setting a genus's name to an existing one
    Given there is a genus "Calyptites"
    And there is a genus "Atta"
    And I log in
    When I go to the edit page for "Atta"
    And I click the name field
    And I set the name to "Calyptites"
    And I press "OK"
    Then I should see "This name is in use by another taxon. To create a homonym, click"
    And I press "Save homonym"
    Then I should not see "This name is in use by another taxon. To create a homonym, click"

  Scenario: Cancelling
    Given there is a genus "Calyptites"
    And I log in
    When I go to the edit page for "Calyptites"
    And I select "subfamily" from "taxon_incertae_sedis_in"
    And I press "Cancel"
    Then I should not see "incertae sedis" in the header

  Scenario: Changing the protonym name
    Given there is a genus "Atta" with protonym name "Atta"
    And there is a genus "Eciton"
    And I log in
    When I go to the edit page for "Atta"
    And I click the protonym name field
    And I set the protonym name to "Eciton"
    And I press "OK"
    And I save my changes
    Then I should see "Eciton" in the headline

  Scenario: Changing the authorship
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    Given there is a genus "Eciton"
    And I log in
    When I go to the edit page for "Eciton"
    And I click the authorship field
    And I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    Then the authorship field should contain "Fisher 2004. Ants. Psyche 3:3."
    When I fill in the authorship notes with "Authorship notes"
    And I fill in "taxon_type_taxt" with "Notes"
    When I save my changes
    Then The taxon mouseover should contain "Fisher 2004. Ants. Psyche 3:3."
    And I should see "Authorship notes" in the headline

  Scenario: Supplying the authorship when there wasn't one before
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    Given there is a genus "Eciton" without protonym authorship
    And I log in
    And I go to the edit page for "Eciton"
    And I click the authorship field
    And I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    And I save my changes
    Then The taxon mouseover should contain "Fisher 2004. Ants. Psyche 3:3."

  Scenario: Changing the authorship but cancelling
    Given there is a genus "Eciton"
    And I log in
    When I go to the edit page for "Eciton"
    And I click the authorship field
    And I press "Cancel"
    Then I should be on the edit page for "Eciton"

  Scenario: Changing the type name
    Given there is a genus "Atta" with type name "Atta major"
    And there is a species "Atta major"
    And there is a species "Atta minor"
    And I log in
    When I go to the edit page for "Atta"
    And I click the type name field
    And I set the type name to "Atta minor"
    And I press "OK"
    And I save my changes
    Then I should see "Atta minor" in the headline

  Scenario: Setting the type name after it was blank
    Given there is a genus "Atta"
    And there is a species "Atta major"
    And I log in
    When I go to the edit page for "Atta"
    And I click the type name field
    And I set the type name to "Atta major"
    And I press "OK"
    And I save my changes
    Then I should see "Atta major" in the headline

  Scenario: Clearing the type name
    Given there is a genus "Atta" with type name "Atta major"
    And I log in
    When I go to the catalog page for "Atta"
    Then I should not see "Atta major" in the headline
    When I press "Edit"
    And I click the type name field
    And I set the type name to ""
    And I press "OK"
    And I save my changes
    Then I should not see "Atta major" in the headline

  Scenario: Changing incertae sedis
    Given there is a genus "Atta" that is incertae sedis in the subfamily
    When I log in
    And I go to the catalog page for "Atta"
    Then I should see "incertae sedis in subfamily"
    When I go to the edit page for "Atta"
    And I select "(none)" from "taxon_incertae_sedis_in"
    And I save my changes
    Then I should be on the catalog page for "Atta"
    Then I should not see "incertae sedis in subfamily"

  Scenario: Changing gender of genus-group name
    Given there is a genus "Atta" with "masculine" name
    When I log in
    And I go to the catalog page for "Atta"
    Then I should see "masculine"
    When I go to the edit page for "Atta"
    And I set the name gender to "neuter"
    And I save my changes
    Then I should be on the catalog page for "Atta"
    And I should see "neuter"

  Scenario: Don't see gender field for species-group names
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the edit page for "Atta major"
    Then I should not see the gender menu
    When I go to the edit page for "Atta"
    Then I should see the gender menu

  Scenario: Changing verbatim type locality
    Given a species exists with a name of "major" and a genus of "Atta"
    When I log in
    And I go to the edit page for "Atta major"
    And I set the verbatim type locality to "San Pedro"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see "San Pedro"
    When I press "Edit"
    Then the verbatim type locality should be "San Pedro"

  Scenario: Don't see verbatim type locality field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the edit page for "Atta"
    Then I should not see the verbatim type locality
    When I go to the edit page for "Atta major"
    Then I should see the verbatim type locality

  Scenario: Changing type specimen repository
    Given a species exists with a name of "major" and a genus of "Atta"
    When I log in
    And I go to the edit page for "Atta major"
    And I set the type specimen repository to "CZN"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see "CZN"
    When I press "Edit"
    Then the type specimen repository should be "CZN"

  Scenario: Don't see verbatim type locality field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the edit page for "Atta"
    Then I should not see the type specimen repository
    When I go to the edit page for "Atta major"
    Then I should see the type specimen repository

  Scenario: Changing type specimen URL
    Given a species exists with a name of "major" and a genus of "Atta"
    And that URL "www.antweb.com" exists
    When I log in
    And I go to the edit page for "Atta major"
    And I set the type specimen URL to "www.antweb.com/"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see a link "www.antweb.com/"
    When I press "Edit"
    Then the type specimen URL should be "www.antweb.com/"

  Scenario: Changing biogeographic region
    Given a species exists with a name of "major" and a genus of "Atta"
    When I log in
    And I go to the edit page for "Atta major"
    And I select "Malagasy" from "taxon_biogeographic_region"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see "Malagasy"
    When I press "Edit"
    Then I should see "Malagasy"

  Scenario: Don't see biogeographic region field for genus-group name
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the edit page for "Atta"
    Then I should not see the biogeographic region
    When I go to the edit page for "Atta major"
    Then I should see the biogeographic region

  Scenario: Clearing the biogeographic_region
    Given a species exists with a name of "major" and a genus of "Atta"
    When I log in
    And I go to the edit page for "Atta major"
    And I select "Malagasy" from "taxon_biogeographic_region"
    And I save my changes
    And I press "Edit"
    And I select "" from "taxon_biogeographic_region"
    And I save my changes
    Then I should not see "Malagasy"

  Scenario: Changing current valid name
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    When I log in
    And I go to the edit page for "Atta major"
    And I click the current valid taxon name field
    And I set the current valid taxon name to "Eciton minor"
    And I press "OK"
    And I save my changes
    When I press "Edit"
    Then the current valid taxon name should be "Eciton minor"
    When I save my changes
    Then I should see "synonym of current valid taxon Eciton minor"
