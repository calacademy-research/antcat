@javascript @editing
Feature: Name field

  Scenario: Existing data
    Given there is a genus called "Atta"
    When I go to the name field test page for a name
    Then in the name picker field display I should see the first name
    And I click the expand icon
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then in the name picker field display I should see "Atta"

  Scenario: Cancelling after changing existing data
    Given there is a genus called "Atta"
    When I go to the name field test page for a name
    Then in the name picker field display I should see the first name
    And I click the expand icon
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then in the name picker field display I should see "Atta"
    When I click the expand icon
    And I press "Cancel"
    And I wait for a bit
    Then in the name picker field display I should see the first name

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
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then in the name picker field display I should see "Atta"
