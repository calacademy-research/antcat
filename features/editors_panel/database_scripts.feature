Feature: Database scripts
  Background:
    Given I am logged in
    And I go to the database scripts page

  Scenario: Results when there are issues
    Given there is a Lasius subspecies without a species
    And I go to the database scripts page

    When I follow "Subspecies without species"
    Then I should see "Lasius specius subspecius"

  Scenario: Displaying database script issues in catalog pages
    Given there is a Lasius subspecies without a species

    When I go to the catalog page for "Lasius specius subspecius"
    Then I should see "This subspecies has no species"

    When I follow "See more similiar."
    Then I should see "Catalog: Subspecies without species"

  Scenario: Show tags, and description with markdown
    Then I should see "regression-test"

    When I follow "Valid taxa listed as another taxons junior synonym"
    Then I should see "See GitHub #279."

  Scenario: Clicking on all scripts just to see if the page renders
    When I open all database scripts once by one
    Then I should have browsed at least 5 database scripts
