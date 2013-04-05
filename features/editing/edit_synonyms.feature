@javascript
Feature: Editing the synonyms section

  Scenario: Seeing the synonyms section
    Given I log in
    And there is a species "Atta major" which is a junior synonym of "Eciton minor"
    When I go to the edit page for "Eciton minor"
    And I should see "Atta major" in the junior synonyms section
