Feature: Using the default reference
  Background:
    Given I log in as a catalog editor
    And this reference exists
      | author     | citation_year |
      | Ward, P.S. | 2010          |

  Scenario: Default reference used for new taxon
    Given the Formicidae family exists

    When I go to the page of the reference "Ward, 2010"
    And I follow "Make default"
    Then I should see "Ward, 2010 was successfully set as the default reference"

    When I go to the catalog page for "Formicidae"
    And I follow "Add subfamily"
    Then the authorship should contain the reference "Ward, 2010"
