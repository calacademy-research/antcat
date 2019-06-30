@javascript
Feature: Autocompletion (taxon-related)
  Background:
    Given I am logged in as a catalog editor
    And there is a species "Atta major" with genus "Atta"

  Scenario: Autocompleting protonym localities
    Given there is a genus located in "Africa"

    When I go to the catalog page for "Atta"
    And I follow "Add species"
    And I start filling in ".locality-autocomplete-js-hook" with "A"
    Then I should see the following autocomplete suggestions:
      | Africa |
