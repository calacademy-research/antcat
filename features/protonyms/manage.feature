Feature: Manage protonyms
  Background:
    Given I log in as a helper editor

  Scenario: Editing a protonym
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    Then I should see "page 9"
    And I should see "dealate queen"

    When I follow "Edit"
    And I fill in "protonym_authorship_attributes_pages" with "page 35"
    And I fill in "protonym_authorship_attributes_forms" with "male"
    And I fill in "protonym_locality" with "Lund"
    And I select "Malagasy" from "protonym_biogeographic_region"
    And I press "Save"
    Then I should see "Protonym was successfully updated"
    And I should see "page 35"
    And I should see "male"
    And I should see "LUND"
    And I should see "Malagasy"

  Scenario: Editing type fields
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    Then I should see "page 9"
    And I should see "dealate queen"

    When I follow "Edit"
    And I fill in "protonym_primary_type_information_taxt" with "Madagascar: Prov. Tolliara"
    And I fill in "protonym_secondary_type_information_taxt" with "A neotype had also been designated"
    And I fill in "protonym_type_notes_taxt" with "Note: Typo in Toliara"
    And I press "Save"
    Then I should see "Protonym was successfully updated"
    And I should see "Madagascar: Prov. Tolliara"
    And I should see "A neotype had also been designated"
    And I should see "Note: Typo in Toliara"
