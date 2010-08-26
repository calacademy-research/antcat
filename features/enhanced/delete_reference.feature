Feature: Delete reference
  As Phil Ward
  I want to delete a reference
  So that I can add one to test, then delete it right away
  Or so I can delete one that turns out to have been a duplicate

  Scenario: Not logged in
    Given I am not logged in
      Given the following entries exist in the bibliography
      |authors   |citation|year|title|
      |Fisher, B.|citation|year|title|
    When I go to the main page
      Then I should see "Fisher, B."
    Given I will confirm on the next step
    When I click the reference
    Then I should not see a "Delete" button

  Scenario: Delete a reference
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |citation|year|title|
      |Fisher, B.|citation|year|title|
    When I go to the main page
      Then I should see "Fisher, B."
    Given I will confirm on the next step
    When I click the reference
      And I press "Delete"
    Then "Fisher, B." should not be visible
