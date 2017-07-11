Feature: Reference sections
  Background:
    Given I am logged in

  Scenario: Filtering reference sections by search query
    Given there is a reference section with the references_taxt "typo of Forel"
    And there is a reference section with the references_taxt "typo of August"

    When I go to the reference sections page
    Then I should see "typo of Forel"
    And I should see "typo of August"

    When I fill in "q" with "Forel"
    And I press "Filter"
    Then I should see "typo of Forel"
    And I should not see "typo of August"

    When I fill in "q" with "asdasdasd"
    And I press "Filter"
    Then I should not see "typo of Forel"
    And I should not see "typo of August"
