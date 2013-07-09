@javascript
Feature: Workflow

  Background:
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And I log in

  Scenario: Adding a taxon and seeing it on the Changes page
    When I go to the changes page
    Then I should not see a change for "Atta"
    When I add the genus "Atta"
    And I go to the changes page
    Then I should see a change for "Atta"
