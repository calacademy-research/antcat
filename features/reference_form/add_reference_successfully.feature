Feature: Add reference
  Background:
    Given I log in as a helper editor
    And I go to the references page
    And I follow "New"

  Scenario: Adding an `ArticleReference`
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I fill in "reference_bolton_key" with "Ward, B.L. & Bolton, B., 1981a"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_series_volume_issue" with "1"
    And I fill in "reference_pagination" with "2"
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ant Journal 1:2"
    And I should see "Ward B.L. Bolton B. 1981a"

  Scenario: Adding a `BookReference`
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I select the reference tab "#book-tab"
    And I fill in "reference_publisher_string" with "New York: Houghton Mifflin"
    And I fill in "reference_pagination" with "32 pp."
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."

  Scenario: Adding a `NestedReference`
    Given this article reference exists
      | author     | title          | citation_year | citation   |
      | Ward, P.S. | Annals of Ants | 2010          | Psyche 1:1 |

    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I select the reference tab "#nested-tab"
    And I fill in "reference_pagination" with "Pp. 32-33 in:"
    And I fill in "reference_nesting_reference_id" with the ID for "Annals of Ants"
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Annals of Ants. Psyche 1:1"
