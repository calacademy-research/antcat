@javascript @editing
Feature: Name field

  Scenario: Blank name
    When I go to the name field test page
    And I click the expand icon
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"

  Scenario: Find typed taxon
    Given there is a genus called "Atta"
    When I go to the name field test page
    And I click the expand icon
    And I fill in "name" with "Atta"
    And I press "OK"
    Then in the name picker field display I should see "Atta"

  Scenario: Can't find taxon
    When I go to the name field test page
    And I click the expand icon
    And I fill in "name" with "Atta"
    And I press "OK"
    Then I should see "The name 'Atta' was not found"
