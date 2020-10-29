Feature: History items
  Background:
    Given I am logged in

  Scenario: Filtering history items by search query
    Given there is a history item "typo of Forel"
    And there is a history item "typo of August"

    When I go to the history items page
    Then I should see "typo of Forel"
    And I should see "typo of August"

    When I fill in "q" with "Forel"
    And I press "Search"
    Then I should see "typo of Forel"
    And I should not see "typo of August"

    When I fill in "q" with "asdasdasd"
    And I press "Search"
    Then I should not see "typo of Forel"
    And I should not see "typo of August"
