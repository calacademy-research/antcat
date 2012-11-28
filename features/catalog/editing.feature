Feature: Editing
  As an editor of AntCat
  I want to edit the catalog
  But only if I take a special step
  So that the editing interface isn't always visible

  Scenario: Turn on editing mode
    Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    And I am logged in
    When I go to the catalog entry for "Solenopsis invicta"
    Then I should not see the editing buttons
    When I turn on editing mode
    And I go to the catalog entry for "Solenopsis invicta"
    Then I should see the editing buttons

  Scenario: Turn off editing mode
    Given there is a species "Solenopsis invicta" which is a junior synonym of "Solenopsis wagneri"
    And I am logged in as an editor and have editing turned on
    When I go to the catalog entry for "Solenopsis invicta"
    Then I should see the editing buttons
    When I turn off editing mode
    And I go to the catalog entry for "Solenopsis invicta"
    Then I should not see the editing buttons
