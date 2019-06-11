@papertrail
Feature: Versions (filtering)
  Background:
    Given I am logged in as a catalog editor

  Scenario: Filtering versions by event
    Given a journal exists with a name of "Psyche"
    And I go to the references page
    And I follow "Journals"
    And I follow "Psyche"
    And I follow "Delete"

    When I go to the versions page
    Then I should see 3 versions

    When I select "destroy" from "event"
    And I press "Filter"
    Then I should see 1 version

    When I follow "Clear"
    Then I should see 3 versions

  Scenario: Filtering versions by search query
    Given a journal exists with a name of "Psyche"

    When I go to the versions page
    Then I should see 1 version

    When I fill in "q" with "Psyche"
    And I press "Filter"
    Then I should see 1 version

    When I fill in "q" with "asdasdasd"
    And I press "Filter"
    Then I should see 0 versions
