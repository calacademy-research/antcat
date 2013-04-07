@javascript
Feature: Editing the synonyms section

  Background:
    Given I log in

  Scenario: Seeing the synonyms section
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    And I should see "Atta major" in the junior synonyms section

  Scenario: Adding a synonym
    Given there is a genus "Atta"
    Given there is a species "Atta major"
    And there is a species "Atta minor"
    When I go to the edit page for "Atta major"
    And I should not see "Atta major" in the junior synonyms section
    When I press "Add" in the junior synonyms section
    And I fill in the blank with "Atta minor"

  Scenario: Deleting a synonym
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    And I should see "Atta major" in the junior synonyms section
    Given I will confirm on the next step
    When I click "Delete" beside the first junior synonym
    Then I should not see "Atta major" in the junior synonyms section
