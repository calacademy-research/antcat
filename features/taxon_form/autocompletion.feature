@javascript
Feature: Autocompletion (taxon-related)
  Background:
    Given I log in as a catalog editor
    And there is a species "Atta major" in the genus "Atta"

  Scenario: Autocompleting protonym localities
    Given there is a genus located in "Mexico"

    When I go to the catalog page for "Atta"
    And I follow "Add species"
    And I start filling in ".locality-autocomplete-js-hook" with "M"
    Then I should see the following autocomplete suggestions:
      | Mexico |
