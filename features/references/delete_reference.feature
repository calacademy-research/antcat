@dormant @javascript
Feature: Delete reference
  As Phil Ward
  I want to delete a reference
  So that I can add one to test, then delete it right away
  Or so I can delete one that turns out to have been a duplicate

  Scenario: Delete a reference
    And the following references exist
      | authors    | citation   | year | title |
      | Fisher, B. | Psyche 2:1 | year | title |
    And I am logged in
    And I go to the references page
    Then I should see "Fisher, B."
    Given I will confirm on the next step
    When I follow "edit"
    And I press the "Delete" button
    Then I should not see "Fisher, B."

