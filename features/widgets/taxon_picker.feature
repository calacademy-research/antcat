@javascript @editing
Feature: Taxon picker

  Scenario: Blank taxon name
    When I go to the taxon picker test page
    And I press "OK"
    Then I should see "Name can't be blank"
