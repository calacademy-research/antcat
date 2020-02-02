Feature: Edit reference successfully
  Background:
    Given I log in as a helper editor

  @javascript
  Scenario: Change a reference's type
    Given this reference exists
      | author     | title | citation   | citation_year |
      | Fisher, B. | Ants  | Psyche 6:4 | 2010          |

    When I go to the edit page for the most recent reference
    And I follow "Book"
    And I fill in "reference_publisher_string" with "New York: Wiley"
    And I fill in "reference_pagination" with "22 pp."
    And I press "Save"
    Then I should see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."

  Scenario: See the correct tab initially (book reference)
    Given there is a book reference

    When I go to the edit page for the most recent reference
    Then the "Book" tab should be selected

  Scenario: See the correct tab initially (unknown reference)
    Given there is an unknown reference

    When I go to the edit page for the most recent reference
    Then the "Other" tab should be selected

  Scenario: Specifying the document URL
    Given there is a reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_document_attributes_url" with a URL to a document that exists
    And I press "Save"
    Then I should see a PDF link

  Scenario: Edit a nested reference
    Given this reference exists
      | author     | citation   | citation_year | title |
      | Ward, P.S. | Psyche 5:3 | 2001          | Ants  |
    And the following entry nests it
      | author     | title            | citation_year | pages_in |
      | Bolton, B. | Ants are my life | 2001          | In:      |

    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"

    When I go to the edit page for the most recent reference
    And I fill in "reference_pages_in" with "Pp. 32 in:"
    And I press "Save"
    Then I should see "Bolton, B. 2001. Ants are my life. Pp. 32 in: Ward, P.S. 2001. Ants. Psyche 5:3"
