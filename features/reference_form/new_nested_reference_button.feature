Feature: Add new nested reference button
  Scenario: Add new `NestedReference` using the button
    Given this article reference exists
      | citation_year | citation   |
      | 2010          | Psyche 1:1 |
    And I log in as a helper editor

    When I go to the page of the most recent reference
    And I follow "New Nested Reference"
    Then the "reference_citation_year" field should contain "2010"
    And the "reference_pagination" field should contain "Pp. XX-XX in:"
    And nesting_reference_id should contain a valid reference id
