@javascript
Feature: Workflow
  As an editor of AntCat
  I want to change a taxon's parent
  and then undo that change
  so mistakes can be repaired

  Background:
    Given I am logged in
    And version tracking is enabled

  @wip
  Scenario: Changing a species's genus twice by using the helper link
    Given there is an original species "Atta major" with genus "Atta"
    And there is a genus "Becton"
    And there is a genus "Chatsworth"

  # Change parent from A -> B
    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Becton"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"
    When I press "Yes, create new combination"
    When I save my changes

  # Change parent from B -> C
    When I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"
    When I press "Yes, create new combination"
    Then the name field should contain "Chatsworth major"
    When I save my changes

  # We are now on the catalog page after doing A -> B -> C
    Then I should be on the catalog page for "Chatsworth major"
    And the name in the header should be "Chatsworth major"
    When I go to the catalog page for "Atta major"
    Then I should see "see Chatsworth major"
    When I go to the catalog page for "Becton major"
    Then I should see "an obsolete combination of Chatsworth major"

  @wip
  Scenario: Adding a taxon and seeing it on the Changes page, undoing it
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
    Then I should see "This taxon has been changed and is awaiting approval"
    * I should see the name "Atta" in the changes