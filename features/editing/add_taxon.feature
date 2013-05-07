@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept up-to-date
  So people use AntCat

  Scenario: Adding a genus
    Given there is a subfamily "Formicinae"
    And I log in
    When I go to the edit page for "Formicinae"
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
    And I save my changes

  Scenario: Having an error, but leave fields as user entered them
    When I log in
    And I go to the new taxon page
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should see "Name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
