@javascript @editing
Feature: Reference field

  Background:
    Given there is a reference by Brian Fisher
    And there is a reference by Barry Bolton

  Scenario: Setting a reference when there wasn't one before
    When I go to the reference field widget test page
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Fisher

  Scenario: Changing the reference
    When I go to the reference field widget test page
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Fisher
    When I search for the author "Bolton, B."
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Bolton

  Scenario: Cancelling
    When I go to the reference field widget test page
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "Cancel"
    Then the field should contain "(none)"

  Scenario: Adding a reference
    Given there are no references
    When I go to the reference field widget test page
    Then I should see "No reference selected"
    And I add a reference by Brian Fisher
    And I press "OK"
    Then the field should contain the reference by Fisher
