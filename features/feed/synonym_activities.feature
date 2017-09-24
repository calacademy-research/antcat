@feed @javascript
Feature: Feed (synonyms)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added synonym
    Given activity tracking is disabled
      And there is a species "Atta major"
      And there is a species "Atta minor"
    And activity tracking is enabled

    When I go to the edit page for "Atta major"
      And I press "Add" in the junior synonyms section
      And I fill in the junior synonym name with "Atta minor"
      And I save the synonym
    Then I should see "Atta minor" in the junior synonyms section

    When I go to the activity feed
    Then I should see "Archibald added the synonym relationship Atta minor (junior)" and no other feed items
    And I should see "Atta major (senior)"

  Scenario: Deleted synonym
    Given activity tracking is disabled
      And there is a species "Atta major" which is a junior synonym of "Eciton minor"
    And activity tracking is enabled

    When I go to the edit page for "Eciton minor"
      And I will confirm on the next step
      And I click "Delete" beside the first junior synonym
      And I wait
    And I go to the activity feed
    Then I should see "Archibald deleted the synonym relationship Atta major (junior)" and no other feed items
    And I should see "Eciton minor (senior)"
