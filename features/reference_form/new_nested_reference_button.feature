Feature: Add new nested reference button
  Scenario: Add new nested reference using the button
    Given this reference exists
      | author     | title          | citation_year | citation   |
      | Ward, P.S. | Annals of Ants | 2010          | Psyche 1:1 |
    And I am logged in

    When I go to the page of the most recent reference
    And I follow "New Nested Reference"
    Then the "reference_citation_year" field should contain "2010"
    And the "reference_pages_in" field should contain "Pp. XX-XX in:"
    And nesting_reference_id should contain a valid reference id
