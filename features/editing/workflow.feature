@javascript
Feature: Workflow

  Background:
    Given I log in as a catalog editor
    And these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And there is a genus "Eciton"
    And version tracking is enabled

    #expected failure due to reference picker problem.
  Scenario: Adding a taxon and seeing it on the Changes page
    When I go to the catalog page for "Formicinae"
    * I press "Edit"
    * I press "Add genus"
    * I click the name field
    * I set the name to "Atta"
    * I press "OK"
    * I select "subfamily" from "taxon_incertae_sedis_in"
    * I check "Hong"
    * I fill in "taxon_headline_notes_taxt" with "Notes"
    * I click the protonym name field
    * I set the protonym name to "Eciton"
    * I check "taxon_protonym_attributes_sic"
    * I press "OK"
    * I click the authorship field
    * I search for the author "Fisher"
    * I click the first search result
    * I press "OK"
    * I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "260"
    * I fill in "taxon_protonym_attributes_authorship_attributes_forms" with "m."
    * I fill in "taxon_protonym_attributes_authorship_attributes_notes_taxt" with "Authorship notes"
    * I fill in "taxon_protonym_attributes_locality" with "Africa"
    * I click the type name field
    * I set the type name to "Atta major"
    * I press "OK"
    * I press "Add this name"
    * I check "taxon_type_fossil"
    * I fill in "taxon_type_taxt" with "Type notes"
    * I save my changes
    * I press "Edit"
    * I add a history item "History item"
    * I add a reference section "Reference section"
    * I go to the catalog page for "Atta"
    Then I should see "This taxon has been changed; changes awaiting approval"
    When I press "Review change"
    * I should see the name "Atta" in the changes
    * I should see the subfamily "Formicinae" in the changes
    * I should see the status "valid" in the changes
    * I should see the incertae sedis status of "subfamily" in the changes
    * I should see the attribute "Hong" in the changes
    * I should see the notes "Notes" in the changes
    * I should see the protonym name "Eciton" in the changes
    * I should see the protonym attribute "sic" in the changes
    * I should see the authorship reference "Fisher 2004. Ants. Psyche 3:3." in the changes
    * I should see the page "260" in the changes
    * I should see the forms "m." in the changes
    * I should see the authorship notes "Authorship notes" in the changes
    * I should see the locality "Africa" in the changes
    * I should see the type name "Atta major" in the changes
    * I should see the type attribute "Fossil" in the changes
    * I should see the type notes "Type notes" in the changes
    * I should see a history item "History item" in the changes
    * I should see a reference section "Reference section" in the changes
    When I follow "Atta"
    Then I should be on the catalog page for "Atta"


  Scenario: Approving a change
    When I add the genus "Atta"
    And I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden" in the change history
    When I log in as a catalog editor named "Stan Blum"
    When I go to the changes page
    And I will confirm on the next step
    And I press "Approve"
    Then I should not see "Approve"
    And I should see "Stan Blum approved"
    When I go to the catalog page for "Atta"
    Then I should see "approved by Stan Blum"


  Scenario: Another editor editing a change that's waiting for approval
    When I add the genus "Atta"
    And I go to the changes page
    Then I should see "Mark Wilden added"
    When I log in as a catalog editor named "Stan Blum"
    And I go to the changes page
    And I press "Edit"
    And I select "genus" from "taxon_incertae_sedis_in"
    And I save my changes
    When I press "Review change"
    Then I should see the incertae sedis status of "genus" in the changes
    And I should see "Stan Blum changed"
    When I log in as a catalog editor named "Mark Wilden"
    And I go to the changes page
    Given I will confirm on the next step
    And I press the first "Approve"
    Then I should see "Mark Wilden approved"
    When I go to the catalog page for "Atta"
    Then I should see "approved by Mark Wilden"

  Scenario: Trying to approve one's own change
    When I add the genus "Atta"
    And I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden" in the change history
    When I go to the changes page
    Then I should not see an "Approve" button


  Scenario: Editing a taxon - modified, not added
    Given there is a family "Formicidae"
    And I log in
    When I go to the edit page for "Formicidae"
    And I click the name field
    And I set the name to "Wildencidae"
    And I press "OK"
    And I press "Save" within ".buttons_section"
    Then I should see "Wildencidae" in the header
    And I should see "Changed by Mark Wilden"
    And I should see "This taxon has been changed; changes awaiting approval"
    And I go to the changes page
    And I should see "Mark Wilden changed Wildencidae"

  Scenario: People's names linked to their email
    When I add the genus "Atta"
    And I go to the changes page
    Then I should see "Mark Wilden added"
    And there should be a mailto link to the email of "Mark Wilden"
    When I log in as a catalog editor named "Stan Blum"
    When I go to the changes page
    And I will confirm on the next step
    And I press "Approve"
    Then I should not see "Approve"
    And I should see "Stan Blum approved"
    And there should be a mailto link to the email of "Stan Blum"
    And there should be a mailto link to the email of "Mark Wilden"
    When I go to the catalog page for "Atta"
    Then I should see "Added by Mark Wilden"
    And there should be a mailto link to the email of "Mark Wilden"
    Then I should see "approved by Stan Blum"
    And there should be a mailto link to the email of "Stan Blum"
