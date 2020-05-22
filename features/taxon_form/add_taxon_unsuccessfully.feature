Feature: Adding a taxon unsuccessfully
  Background:
    Given I log in as a catalog editor
    And there is a subfamily "Formicinae"

  Scenario: Having an errors, and maintain entered fields
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I set the name to "Atta prolasius"
    And I select "homonym" from "taxon_status"
    And I press "Save"
    Then I should see "Homonym replaced by must be set for homonyms"
    And I should see "Rank (`Genus`) and name type (`SpeciesName`) must match."
    And I should see "Protonym: Name can't be blank"
    And I should see "Protonym: Authorship: Reference must exist"
    And I should see "Protonym: Authorship: Pages can't be blank"
    And the "taxon_name_string" field should contain "Atta prolasius"

  Scenario: Unparsable names, and maintain entered fields
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I set the name to "Invalid a b c d e f taxon name"
    And I set the protonym name to "Invalid a b c d e f protonym name"
    And I press "Save"
    Then I should see "Name: Could not parse name Invalid a b c d e f taxon name"
    And I should see "Protonym: Protonym name: Could not parse name Invalid a b c d e f protonym name"
    And the "taxon_name_string" field should contain "Invalid a b c d e f taxon name"
    And the "protonym_name_string" field should contain "Invalid a b c d e f protonym name"
