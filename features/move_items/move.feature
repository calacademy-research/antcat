@javascript
Feature: Move items
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Moving reference sections (with feed)
    Given there is a subfamily "Antcatinae" with a reference section "Antcatinae section"
    And there is a genus "Formica"

    When I go to the catalog page for "Antcatinae"
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
    Then I should see "Successfully moved items"

    When I go to the catalog page for "Formica"
    And I should see "Antcatinae section"

    When I go to the activity feed
    Then I should see "Archibald moved items belonging to Antcatinae to Formica" within the activity feed

  Scenario: Moving history items (with feed)
    Given there is a subfamily protonym "Antcatinae" with a history item "Antcatinae history"
    And there is a genus protonym "Formica"

    When I go to the protonym page for "Antcatinae"
    And I follow "Move items"
    Then I should see "Move items › Select target"

    When I press "Select..."
    Then I should see "Target must be specified"

    When I pick "Formica" from the "to_protonym_id" protonym selector
    And I press "Select..."
    Then I should see "Move items › to Formica"

    When I press "Move selected items"
    Then I should see "At least one item must be selected"

    When I follow "Select all"
    And I press "Move selected items"
    Then I should see "Successfully moved items"

    When I go to the protonym page for "Formica"
    And I should see "Antcatinae history"

    When I go to the activity feed
    Then I should see "Archibald moved protonym items belonging to Antcatinae to Formica" within the activity feed
