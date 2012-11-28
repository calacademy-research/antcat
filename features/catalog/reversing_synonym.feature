Feature: Reversing synonymy
  As a user of AntCat
  I want change the direction of a synonymy
  So that the junior is now the senior and vice versa
  Because the relationship was incorrectly parsed
  And we want it to be correct

  Scenario: Reversing synonym from the junior side
    Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    And I am logged in as an editor and have editing turned on
    When I go to the catalog entry for "Solenopsis invicta"
    Then I should see that "Solenopsis invicta" is a synonym of "Solenopsis wagneri"
    #Given that I will confirm on the next step
    When I press "Reverse synonymy"
    Then I should see the catalog entry for "Solenopsis invicta"
    Then I should not see that "Solenopsis invicta" is a synonym of "Solenopsis wagneri"
    When I go to the catalog entry for "Solenopsis wagneri"
    Then I should see that "Solenopsis wagneri" is a synonym of "Solenopsis invicta"

  Scenario: Reversing synonym from the senior side
  Scenario: Can't see buttons if not logged in as editor
  Scenario: Can't see buttons if editing not turned on
  Scenario: Pushing the button but not confirming
