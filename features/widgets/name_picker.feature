@javascript @editing
Feature: Name picker

  Scenario: Blank name
    When I go to the name picker test page
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"

  Scenario: Find typed taxon
    Given there is a genus called "Atta"
    When I go to the name picker test page
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then in the results section I should see the id for "Atta"
    And in the results section I should see the editable taxt for "Atta"

  Scenario: Can't find taxon
    When I go to the name picker test page
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then I should see "The name 'Atta' was not found"
