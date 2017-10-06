@javascript
Feature: Name popup
  Background:
    Given I am logged in

  Scenario: Blank name
    When I go to the name popup test page
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"

  Scenario: Find typed taxon
    Given there is a genus "Atta"

    When I go to the name popup test page
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then in the results section I should see the id for "Atta"
    And in the results section I should see the editable taxt for "Atta"

  Scenario: Find typed name
    Given there is a species name "Eciton major"

    When I go to the name popup test page
    And I fill in "name_string" with "Eciton major"
    And I press "OK"
    Then in the results section I should see the id for the name "Eciton major"
    And in the results section I should see the editable taxt for the name "Eciton major"

  Scenario: Adding a name
    When I go to the name popup test page
    And I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."

    When I press "Add this name"
    And I wait
    Then in the results section I should see the id for the name "Atta wildensis"
    And in the results section I should see the editable taxt for the name "Atta wildensis"

  Scenario: Entering a new name, but cancelling instead of adding it
    When I go to the name popup test page
    Then I should see the name popup edit interface

    When I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."

    When I press "Cancel"
    Then I should see the name popup edit interface
