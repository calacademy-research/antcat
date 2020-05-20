Feature: Adding a taxon unsuccessfully
  Background:
    Given I log in as a catalog editor
    And there is a subfamily "Formicinae"

  Scenario: Having an error, but leave fields as user entered them
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
