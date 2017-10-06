@javascript
Feature: Reversing synonymy
  As a user of AntCat
  I want change the direction of a synonymy
  So that the junior is now the senior and vice versa
  Because the relationship was incorrectly parsed
  And we want it to be correct

  Background:
    Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    And I am logged in

  Scenario: Reversing synonym from the senior side
    When I go to the edit page for "Solenopsis wagneri"
    Then I should see "Solenopsis invicta" in the junior synonyms section

    Given I will confirm on the next step
    When I click "Reverse synonymy" beside the first junior synonym
    Then I should not see "Solenopsis invicta" in the junior synonyms section
    And I should see "Solenopsis invicta" in the senior synonyms section

  Scenario: Reversing synonym from the junior side
    When I go to the edit page for "Solenopsis invicta"
    Then I should see "Solenopsis wagneri" in the senior synonyms section

    Given I will confirm on the next step
    When I click "Reverse synonymy" beside the first senior synonym
    Then I should not see "Solenopsis wagneri" in the senior synonyms section
    And I should see "Solenopsis wagneri" in the junior synonyms section
