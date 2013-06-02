@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept up-to-date
  So people use AntCat

  Background:
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And I log in

  Scenario: Adding a genus
    Given there is a genus "Eciton"
    When I go to the catalog page for "Formicinae"
    And I press "Edit"
    And I press "Add genus"
    Then I should be on the new taxon page
    When I click the epithet field
      And I set the epithet to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    And I save my changes
    Then I should be on the catalog page for "Atta"
    When I go to the catalog page for "Formicinae"
    And I should see "Atta" in the index
    And I should see "Eciton" in the protonym

  Scenario: Adding a genus without setting authorship reference
    Given there is a genus "Eciton"
    When I go to the edit page for "Formicinae"
    And I press "Add genus"
    Then I should be on the new taxon page
    When I click the epithet field
      And I set the epithet to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
    And I press "Add this name"
    And I save my changes
    Then I should see "Protonym authorship reference can't be blank"

  Scenario: Having an error, but leave fields as user entered them
    When I go to the edit page for "Formicinae"
    And I press "Add genus"
    And I click the epithet field
      And I set the epithet to "Atta"
      And I press "OK"
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should be on the create taxon page
    And I should see "Protonym name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
    And the name field should contain "Atta"

  Scenario: Cancelling
    And I go to the edit page for "Formicinae"
    And I press "Add genus"
    And I press "Cancel"
    Then I should be on the edit page for "Formicinae"

  Scenario: Adding a species
    Given there is a genus "Eciton"
    When I go to the catalog page for "Eciton"
    And I press "Edit"
    And I press "Add species"
    Then I should be on the new taxon page
    And I should see "new species of "
    And I should see "Eciton"
    When I click the epithet field
      And I set the epithet to "Eciton major"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Eciton major"
    When I go to the catalog page for "Eciton"
    And I should see "major" in the index
    And I should see "Eciton major" in the protonym

  Scenario: Using a genus's type-species for the name of a species
    When I go to the catalog page for "Formicinae"
    And I press "Edit"
    And I press "Add genus"
    And I click the epithet field
      And I set the epithet to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Atta"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    And I save my changes
    And I press "Edit"
    And I press "Add species"
    When I click the epithet field
      And I set the epithet to "Atta major"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Atta major"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Atta major"
    And I should see "Atta major" in the protonym

  Scenario: Adding a subspecies
    Given there is a genus "Eciton"
    And there is a species "Eciton major" with genus "Eciton"
    When I go to the catalog page for "Eciton major"
    And I press "Edit"
    And I press "Add subspecies"
    Then I should be on the new taxon page
    And I should see "new subspecies of Eciton major"
    When I click the epithet field
      And I set the epithet to "Eciton major infra"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major infra"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I save my changes
    Then I should be on the catalog page for "Eciton major infra"
    And I should see "infra" in the index
