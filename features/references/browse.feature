Feature: View bibliography
  Scenario: Viewing a nested reference (with italics)
    Given there is a book reference
    And the following entry nests it
      | author     | title                    | citation_year | pages_in |
      | Ward, P.S. | The ant *Azteca trigona* | 2010          | In:      |

    When I go to the references page
    Then I should see "Ward, P.S. 2010. The ant Azteca trigona. In: "
    And I should see "Azteca trigona" italicized

  Scenario: Viewing a missing reference
    Given this reference exists
      | author     | title     |
      | Ward, P.S. | Ant Facts |
    And there is a missing reference

    When I go to the references page
    Then I should not see the missing reference
    And I should see "Ant Facts"

  Scenario: Going to the author's page
    Given this reference exist
      | author     | title     |
      | Bolton, B. | Cool Ants |

    When I go to the page of the most recent reference
    And I follow "Bolton, B."
    Then I should see "References by author"
    And I should see "Cool Ants"
