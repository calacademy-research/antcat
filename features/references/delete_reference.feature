@dormant @javascript
Feature: Delete reference
  As Phil Ward
  I want to delete a reference
  So that I can add one to test, then delete it right away
  Or so I can delete one that turns out to have been a duplicate

  Scenario: Delete a reference
    Given the following references exist
      | authors    | citation   | year | title |
      | Fisher, B. | Psyche 2:1 | year | title |
    And I am logged in
    When I go to the references page
    * I will confirm on the next step
    * I follow "edit"
    * I press the "Delete" button
    Then I should not see "Fisher, B."

  @preview
  Scenario: Delete a reference when not logged in, but in preview mode
    Given the following references exist
      | authors    | citation   | year | title |
      | Fisher, B. | Psyche 2:1 | year | title |
    And I am not logged in
    When I go to the references page
    * I will confirm on the next step
    * I follow "edit"
    * I press the "Delete" button
    Then I should not see "Fisher, B."

