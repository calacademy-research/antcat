@javascript
Feature: Using the default reference
  Background:
    Given I am logged in as a catalog editor
    And this reference exists
      | author     | citation_year |
      | Ward, P.S. | 2010          |

  Scenario: Default reference used for new taxon
    Given there is a genus "Atta"
    And the default reference is "Ward, 2010"

    When I go to the catalog page for "Atta"
    And I follow "Add species"
    Then the authorship should contain the reference "Ward, 2010"
