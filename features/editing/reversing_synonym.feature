@javascript
Feature: Reversing synonymy
  As a user of AntCat
  I want change the direction of a synonymy
  So that the junior is now the senior and vice versa
  Because the relationship was incorrectly parsed
  And we want it to be correct

  Scenario: Reversing synonym from the senior side
    Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    And I am logged in
    When I go to the edit page for "Solenopsis wagneri"
    Then I should see "Solenopsis invicta" in the junior synonyms section
    Given I will confirm on the next step
    When I click "Reverse synonymy" beside the first junior synonym
    Then I should not see "Solenopsis invicta" in the junior synonyms section
    #And I should see "Solenopsis invicta" in the senior synonyms section

  #Scenario: Reversing synonym from the junior side
    #Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    #And I am logged in
    #When I go to the catalog entry for "Solenopsis invicta"
    #Then I should see that "Solenopsis invicta" is a synonym of "Solenopsis wagneri"
    #When I press "Edit"
    #Given I will confirm on the next step
    #And I press "Reverse synonymy"
    #Then I should see the catalog entry for "Solenopsis invicta"
    #Then I should not see that "Solenopsis invicta" is a synonym of "Solenopsis wagneri"
    #When I go to the catalog entry for "Solenopsis wagneri"
    #Then I should see that "Solenopsis wagneri" is a synonym of "Solenopsis invicta"
    #And there should be an editing history record showing that the new junior synonym is "Solenopsis wagneri" and the new senior synonym is "Solenopsis invicta"
