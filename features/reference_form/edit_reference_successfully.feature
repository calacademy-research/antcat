Feature: Edit reference successfully
  Background:
    Given I log in as a helper editor

  Scenario: Blanking required fields (general fields)
    Given there is an article reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_pagination" with ""
    And I press "Save"
    Then I should see "Author names can't be blank"
    And I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Blanking required fields (`ArticleReference`)
    Given there is an article reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_journal_name" with ""
    And I fill in "reference_series_volume_issue" with ""
    And I press "Save"
    Then I should see "Journal must exist"
    And I should see "Series volume issue can't be blank"

  Scenario: Blanking required fields (`BookReference`)
    Given there is a book reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_publisher_string" with ""
    And I press "Save"
    Then I should see "Publisher must exist"

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

  Scenario: See the correct tab initially (`BookReference`)
    Given there is a book reference

    When I go to the edit page for the most recent reference
    Then the "Book" tab should be selected

  Scenario: See the correct tab initially (`UnknownReference`)
    Given there is an unknown reference

    When I go to the edit page for the most recent reference
    Then the "Other" tab should be selected

  Scenario: Specifying the document URL
    Given there is a reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_document_attributes_url" with a URL to a document that exists
    And I press "Save"
    Then I should see a PDF link

  Scenario: Edit a `NestedReference`
    Given this reference exists
      | author     | citation   | citation_year | title |
      | Ward, P.S. | Psyche 5:3 | 2001          | Ants  |
    And the following entry nests it
      | author     | title            | citation_year | pagination |
      | Bolton, B. | Ants are my life | 2001          | In:        |

    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"

    When I go to the edit page for the most recent reference
    And I fill in "reference_pagination" with "Pp. 32 in:"
    And I press "Save"
    Then I should see "Bolton, B. 2001. Ants are my life. Pp. 32 in: Ward, P.S. 2001. Ants. Psyche 5:3"
