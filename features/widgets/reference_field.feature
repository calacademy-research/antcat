@javascript @editing
Feature: Reference field

  Background:
    Given there is a reference by Brian Fisher
    And there is a reference by Barry Bolton

  Scenario: Setting a reference when there wasn't one before
    When I go to the reference field widget test page
    And I click the expand icon
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Fisher

  Scenario: Changing the reference
    When I go to the reference field widget test page
    And I click the expand icon
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Fisher
    When I click the expand icon
    And I search for the author "Bolton, B."
    And I wait for a bit
    And I click the first search result
    And I press "OK"
    Then the field should contain the reference by Bolton

  #Scenario: Adding a reference
    #Given there are no references
    #When I go to the reference field widget test page
    #And I click the expand icon
    #And I add a reference by Brian Fisher
    #Then the field should contain the reference by Fisher

  Scenario: Cancelling
    When I go to the reference field widget test page
    And I click the expand icon
    And I search for the author "Fisher, B."
    And I click the first search result
    And I press "Cancel"
    And I wait for a bit
    Then the field should contain "(none)"

