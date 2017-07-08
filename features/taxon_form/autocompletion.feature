@javascript
Feature: Autocompletion (taxon-related)
  Background:
    Given I am logged in
    And a species exists with a name of "major" and a genus of "Atta"

  Scenario: Autocompleting type specimen repositories
    Given there is a type specimen repository "CZN"

    When I go to the edit page for "Atta major"
    And I start filling in "#taxon_type_specimen_repository" with "C"
    Then I should see the following autocomplete suggestions:
      | CZN |

  Scenario: Autocompleting protonym localities
    Given there is a genus located in "Africa"

    When I go to the edit page for "Atta major"
    And I start filling in "#taxon_protonym_attributes_locality" with "A"
    Then I should see the following autocomplete suggestions:
      | Africa |
