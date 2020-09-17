Feature: Edit reference successfully
  Background:
    Given I log in as a helper editor

  Scenario: Blanking required fields (general fields)
    Given there is an article reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_year" with ""
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
    Then I should see "Journal: Name can't be blank"
    And I should see "Series volume issue can't be blank"

  Scenario: Blanking required fields (`BookReference`)
    Given there is a book reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_publisher_string" with ""
    And I press "Save"
    Then I should see "Publisher string couldn't be parsed."

  Scenario: Change a reference's type
    Given this article reference exists
      | author     | title | year |
      | Fisher, B. | Ants  | 2010 |

    When I go to the edit page for the most recent reference
    And I select the reference tab "#book-tab"
    And I fill in "reference_publisher_string" with "New York: Wiley"
    And I fill in "reference_pagination" with "22 pp."
    And I press "Save"
    Then I should see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."

  Scenario: Specifying the document URL
    Given there is a reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_document_attributes_url" with a URL to a document that exists
    And I press "Save"
    Then I should see a PDF link

  Scenario: Edit a `NestedReference`
    Given this article reference exists
      | author     | year | title | journal | series_volume_issue | pagination |
      | Ward, P.S. | 2001 | Ants  | Acta    | 4                   | 9          |
    And the following entry nests it
      | author     | title     | year | pagination |
      | Bolton, B. | More ants | 2001 | In:        |

    When I go to the references page
    Then I should see "Bolton, B. 2001. More ants. In: Ward, P.S. 2001. Ants. Acta 4:9"

    When I go to the edit page for the most recent reference
    And I fill in "reference_pagination" with "Pp. 32 in:"
    And I press "Save"
    Then I should see "Bolton, B. 2001. More ants. Pp. 32 in: Ward, P.S. 2001. Ants. Acta 4:9"
