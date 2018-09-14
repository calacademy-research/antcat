Feature: View bibliography
  Scenario: Viewing a nested reference (with italics)
    Given there is a book reference
    And the following entry nests it
      | authors    | title          | year | pages_in |
      | Ward, P.S. | The ant *Azteca trigona* | 2010 | In:      |

    When I go to the references page
    Then I should see "Ward, P.S. 2010. The ant Azteca trigona. In: "
    And I should see "Azteca trigona" italicized

  Scenario: Viewing a missing reference
    Given this reference exists
      | authors    | year | title     | citation |
      | Ward, P.S. | 2010 | Ant Facts | Ants 1:1 |
    And there is a missing reference

    When I go to the references page
    Then I should not see the missing reference
    And I should see "Ward, P.S. 2010. Ant Facts. Ants 1:1"

  Scenario: Going to the author's page
    Given this book reference exist
      | authors    | year | title     | citation                |
      | Bolton, B. | 2010 | Cool Ants | New York: Wiley, 23 pp. |

    When I go to the page of the most recent reference
    And I follow "Bolton, B."
    Then I should see "References by author"
    And I should see "Cool Ants"
