@javascript
Feature: Editing the synonyms section
  Background:
    Given I am logged in

  Scenario: Seeing the synonyms section
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Eciton minor"
    Then I should see "Atta major" in the junior synonyms section

  Scenario: Adding a synonym
    Given there is a species "Atta major"
    And there is a species "Atta minor"

    When I go to the edit page for "Atta major"
    Then I should not see "Atta minor" in the junior synonyms section

    When I press "Add" in the junior synonyms section
    And I fill in the junior synonym name with "Atta minor"
    And I save the synonym
    Then I should be on the edit page for "Atta major"
    And I should see "Atta minor" in the junior synonyms section

  Scenario: Adding a senior synonym
    Given there is a species "Atta major"
    And there is a species "Atta minor"

    When I go to the edit page for "Atta major"
    Then I should not see "Atta minor" in the senior synonyms section

    When I press "Add" in the senior synonyms section
    And I fill in the senior synonym name with "Atta minor"
    And I save the senior synonym
    Then I should be on the edit page for "Atta major"
    And I should see "Atta minor" in the senior synonyms section

  Scenario: Adding two synonyms
    Given there is a species "Atta major"
    And there is a species "Atta minor"
    And there is a species "Atta inbetween"

    When I go to the edit page for "Atta major"
    And I press "Add" in the junior synonyms section
    And I fill in the junior synonym name with "Atta minor"
    And I save the synonym
    And I wait
    And I press "Add" in the junior synonyms section
    And I fill in the junior synonym name with "Atta inbetween"
    And I save the synonym
    Then I should see "Atta minor" in the junior synonyms section
    And I should see "Atta inbetween" in the junior synonyms section

  Scenario: Trying to add a duplicate synonym
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Eciton minor"
    And I press "Add" in the junior synonyms section
    And I fill in the junior synonym name with "Atta major"
    And I save the synonym
    Then I should see "This taxon is already a synonym"

  Scenario: Trying to add a senior synonym when it's already a junior synonym
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Eciton minor"
    And I press "Add" in the senior synonyms section
    And I fill in the senior synonym name with "Atta major"
    And I save the senior synonym
    Then I should see "This taxon is already a synonym"

  Scenario: Deleting a synonym
    Given there is a species "Atta major" which is a junior synonym of "Eciton minor"

    When I go to the edit page for "Eciton minor"
    Then I should see "Atta major" in the junior synonyms section

    Given I will confirm on the next step
    When I click "Delete" beside the first junior synonym
    And I go to the edit page for "Eciton minor"
    Then I should not see "Atta minor" in the junior synonyms section
