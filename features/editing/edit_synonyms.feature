@javascript
Feature: Editing the synonyms section

  Background:
    Given I log in

  Scenario: Seeing the synonyms section
    Given I log in
    And there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    And I should see "Atta major" in the junior synonyms section

  Scenario: Deleting a synonym
    And there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    And I should see "Atta major" in the junior synonyms section
    Given I will confirm on the next step
    When I click "Delete" beside the first junior synonym
    Then I should not see "Atta major" in the junior synonyms section
