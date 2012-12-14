@javascript @editing
Feature: Taxon picker

  Scenario: Blank taxon name
    When I go to the taxon picker test page
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"

  Scenario: Find typed taxon
    Given there is a genus called "Atta"
    When I go to the taxon picker test page
    And I fill in "taxon_name" with "Atta"
    And I press "OK"
    Then in the output section I should see the editable taxt for "Atta"
