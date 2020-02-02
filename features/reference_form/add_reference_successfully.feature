Feature: Add reference
  Background:
    Given I log in as a helper editor
    And I go to the references page
    And I follow "New"

  Scenario: Adding an article
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I fill in "reference_bolton_key" with "Ward, B.L. & Bolton, B., 1981a"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_series_volume_issue" with "1"
    And I fill in "reference_pagination" with "2"
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ant Journal 1:2"
    And I should see "Ward, B.L. & Bolton, B., 1981a"

  @javascript
  Scenario: Adding a book
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Book"
    And I fill in "reference_publisher_string" with "New York: Houghton Mifflin"
    And I fill in "reference_pagination" with "32 pp."
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."

  @javascript
  Scenario: Adding a nested reference
    Given this reference exists
      | author     | title          | citation_year | citation   |
      | Ward, P.S. | Annals of Ants | 2010          | Psyche 1:1 |

    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Nested"
    And I fill in "reference_pages_in" with "Pp. 32-33 in:"
    And I fill in "reference_nesting_reference_id" with the ID for "Annals of Ants"
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Annals of Ants. Psyche 1:1"

  @javascript
  Scenario: Adding an 'Other' reference
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Other"
    And I fill in "reference_citation" with "In Muller, Brown 1928. Ants. p. 23."
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. In Muller, Brown 1928. Ants. p. 23."
