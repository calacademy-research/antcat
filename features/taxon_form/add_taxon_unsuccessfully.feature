Feature: Adding a taxon unsuccessfully
  Background:
    Given I log in as a catalog editor
    And there is a subfamily "Formicinae"

  Scenario: Having an error, but leave fields as user entered them
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I set the name to "Atta prolasius"
    And I fill in "taxon_type_taxt" with "Notes"
    And I press "Save"
    Then I should see "Protonym name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
    And the "taxon_name_string" field should contain "Atta prolasius"
