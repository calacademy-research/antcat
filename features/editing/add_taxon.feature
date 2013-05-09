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
    And I press "Add Genus"
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

  Scenario: Adding a genus without setting authorship reference
    And there is a genus "Eciton"
    And I go to the edit page for "Formicinae"
    And I press "Add Genus"
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
    And I go to the edit page for "Formicinae"
    And I press "Add Genus"
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should be on the create taxon page
    And I should see "Name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"

  Scenario: Cancelling
    And I go to the edit page for "Formicinae"
    And I press "Add Genus"
    And I press "Cancel"
    Then I should be on the edit page for "Formicinae"
