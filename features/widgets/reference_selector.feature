Feature: Reference selector
  Background:
    Given I am logged in as a catalog editor
    And the reference selector returns 2 results per page
    And these references exists
      | author   | citation_year |
      | Fisher   | 2004          |
      | Fisher   | 2004          |
      | Batiatus | 2004          |
    And there is a subfamily "Formicinae"

  @search @javascript
  Scenario: Adding a reference from the autocompletion suggestions
    Given there is a species "Atta major"

    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I set the name to "Atta"
    And I set the type name to "Atta major"
    And I set the protonym name to "Atta"
    And I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "page 35"
    And I set the authorship to the first search results of "Batiatus (2004)"
    Then the authorship should contain the reference "Batiatus, 2004"

    When I press "Save"
    Then I should be on the catalog page for "Atta"
    And I should see "Batiatus, 2004" in the header
