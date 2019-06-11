Feature: View bibliography
  Scenario: Seeing references by author (going to the author's page)
    Given this reference exist
      | author     | title     |
      | Bolton, B. | Cool Ants |

    When I go to the page of the most recent reference
    And I follow the first "Bolton, B."
    Then I should see "References by Bolton, B."
    And I should see "Cool Ants"
