@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept up-to-date
  So people use AntCat

  Scenario: Adding a genus
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    Given there is a subfamily "Formicinae"
    And there is a genus "Eciton"
    And I log in
    And I go to the edit page for "Formicinae"
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
    Given there is a subfamily "Formicinae"
    And there is a genus "Eciton"
    When I log in
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
    When I log in
    And I go to the new taxon page
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should be on the create taxon page
    And I should see "Name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"

