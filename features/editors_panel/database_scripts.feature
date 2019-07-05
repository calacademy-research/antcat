Feature: Database scripts
  Background:
    Given I am logged in
    And I go to the database scripts page

  Scenario: Results when there are issues
    Given there is an extant species Lasius niger in an fossil genus
    And I go to the database scripts page

    When I follow "Extant taxa in fossil genera"
    Then I should see "Lasius niger"

  Scenario: Displaying database script issues in catalog pages
    Given SHOW_SOFT_VALIDATION_WARNINGS_IN_CATALOG is true
    And there is an extant species Lasius niger in an fossil genus

    When I go to the catalog page for "Lasius niger"
    Then I should see "The parent of this taxon is fossil, but this taxon is extant"

    When I follow "See more similiar."
    Then I should see "Catalog: Extant taxa in fossil genera"

  Scenario: Clicking on all scripts just to see if the page renders
    When I open all database scripts once by one
    Then I should have browsed at least 5 database scripts
