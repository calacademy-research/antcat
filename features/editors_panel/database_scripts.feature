Feature: Database scripts
  Background:
    Given I am logged in
    And I go to the database scripts page

  Scenario: Results when there are issues
    Given there is an extant species Lasius niger in a fossil genus
    And I go to the database scripts page

    When I follow "Extant taxa in fossil genera"
    Then I should see "Lasius niger"

  Scenario: Displaying database script issues in catalog pages
    Given these Settings: catalog: { show_failed_soft_validations: false }
    And there is an extant species Lasius niger in a fossil genus

    When I go to the catalog page for "Lasius niger"
    Then I should not see "The parent of this taxon is fossil, but this taxon is extant"

    Given these Settings: catalog: { show_failed_soft_validations: true }
    When I reload the page
    Then I should see "The parent of this taxon is fossil, but this taxon is extant"

    When I follow the first "See more similar."
    Then I should see "Extant taxa in fossil genera"

  Scenario: Clicking on all scripts just to see if the page renders
    Given I open all database scripts one by one

  Scenario: Checking 'empty' status
    Then I should not see "Excluded (slow/list)"

    When I follow "Show empty"
    Then I should see "Excluded (slow/list)"
