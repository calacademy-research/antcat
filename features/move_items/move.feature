@javascript
Feature: Move items
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Moving history items (with feed)
    Given there is a genus "Lasius" with a history item "Best ant in the world"
    And there is a genus "Formica"

    When I go to the catalog page for "Lasius"
    And I follow "Move items"
    Then I should see "Move items › Select target"

    When I press "Select..."
    Then I should see "Target must be specified"

    When I pick "Formica" from the "to_taxon_id" taxon selector
    And I press "Select..."
    Then I should see "Move items › to Formica"

    When I press "Move selected items"
    Then I should see "At least one item must be selected"

    When I follow "Select all"
    And I press "Move selected items"
    Then I should see "Successfully moved history items"

    When I go to the catalog page for "Formica"
    And I should see "Best ant in the world"

    When I go to the activity feed
    Then I should see "Archibald moved items belonging to Lasius to Formica" within the feed
