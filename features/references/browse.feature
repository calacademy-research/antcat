Feature: View bibliography
  Scenario: Viewing a reference with italics
    Given this reference exist
      | author     | title                    |
      | Ward, P.S. | The ant *Azteca trigona* |

    When I go to the references page
    Then I should see "The ant Azteca trigona"
    And I should see "Azteca trigona" italicized

  Scenario: Seeing references by author (going to the author's page)
    Given this reference exist
      | author     | title     |
      | Bolton, B. | Cool Ants |

    When I go to the page of the most recent reference
    And I follow the first "Bolton, B."
    Then I should see "References by author"
    And I should see "Cool Ants"
