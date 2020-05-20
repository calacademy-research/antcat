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

  @search @javascript
  Scenario: Adding a protonym with a type name
    Given there is a genus "Atta"
    And these references exist
      | author   | citation_year |
      | Batiatus | 2004          |

    When I go to the protonyms page
    And I follow "New"
    And I set the protonym name string to "Dotta"
    And I set the type name taxon to "Atta"
    And I set the protonym authorship to the first search results of "Batiatus (2004)"
    And I fill in "protonym_authorship_attributes_pages" with "page 35"
    And I select "by monotypy" from "protonym_type_name_attributes_fixation_method"
    And I press "Save"
    Then I should see "Protonym was successfully created."
    And I should see "Type-genus: Atta, by monotypy"

    When I follow "Edit"
    And I select "by original designation" from "protonym_type_name_attributes_fixation_method"
    And I press "Save"
    Then I should see "Protonym was successfully updated"
    And I should see "Type-genus: Atta, by original designation"

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

  Scenario: Adding a protonym with errors
    When I go to the protonyms page
    And I follow "New"

    When I select "by monotypy" from "protonym_type_name_attributes_fixation_method"
    And I press "Save"
    Then I should see "Name can't be blank"
    And I should see "Authorship: Reference must exist"
    And I should see "Authorship: Pages can't be blank"
    And I should see "Type name: Taxon must exist"

  Scenario: Editing a protonym with errors
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    And I follow "Edit"

    And I fill in "protonym_authorship_attributes_pages" with ""
    When I select "by subsequent designation of" from "protonym_type_name_attributes_fixation_method"
    And I press "Save"
    Then I should see "Authorship: Pages can't be blank"
    And I should see "Type name: Taxon must exist"
    And I should see "Type name: Reference must be set for 'by subsequent designation of'"
    And I should see "Type name: Pages must be set for 'by subsequent designation of'"
