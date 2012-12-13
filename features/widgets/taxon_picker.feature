@javascript @editing
Feature: Taxon picker

  Scenario: Blank taxon name
    When I go to the taxon picker test page
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"
