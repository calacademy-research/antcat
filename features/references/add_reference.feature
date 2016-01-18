@dormant @javascript
Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Background:
    Given the Formicidae family exists
    Given I am logged in
    And these references exist
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |
    And I go to the references page

  Scenario: Add a reference
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "Between Pacific Tides"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1992"
    And I press the "Save" button
    And I should see "Ward, B.L.; Bolton, B. 1992. Between Pacific Tides. Ants 2:1."

  Scenario: Adding a reference but then cancelling
    When I follow "New"
    And I fill in "reference_title" with "Mark Wilden"
    And I press "Cancel"
    Then I should be on the references page

  Scenario: Adding a book
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Book"
    And I fill in "reference_publisher_string" with "New York:Houghton Mifflin"
    And I fill in "book_pagination" with "32 pp."
    And I press the "Save" button
    And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."

  Scenario: Adding an article
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_series_volume_issue" with "1"
    And I fill in "article_pagination" with "2"
    And I press the "Save" button
    And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Nested"
    And I fill in "reference_pages_in" with "Pp. 32-33 in:"
    And I fill in "reference_nesting_reference_id" with the ID for "Annals of Ants"
    And I press the "Save" button
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Annals of Ants. Psyche 1:1 "

  Scenario: Adding an 'Other' reference
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Other"
    And I fill in "reference_citation" with "In Muller, Brown 1928. Ants. p. 23."
    And I press the "Save" button
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. In Muller, Brown 1928. Ants. p. 23."

  Scenario: Leaving other fields blank when adding an article reference
    # TODO pending
    When I follow "New"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button
    Then I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Journal can't be blank"
    And I should see "Series volume issue can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a book reference
    When I follow "New"
    And I follow "Book"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button
    And I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Publisher can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a nested reference
    When I follow "New"
    And I follow "Nested"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button
    And I should see "Year can't be blank"
    And I should see "Pages in can't be blank"
    And I should see "Nesting reference can't be blank"

  Scenario: Adding a reference with authors' role
    When I follow "New"
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B. (eds.)"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_series_volume_issue" with "1"
    And I fill in "article_pagination" with "2"
    And I press the "Save" button
    And I should see "Ward, B.L.; Bolton, B. (eds.) 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference with a nonexistent nestee
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Nested"
    And I fill in "reference_pages_in" with "Pp. 32-33 in:"
    And I fill in "reference_nesting_reference_id" with "123123"
    And I press the "Save" button
    Then I should see "Nesting reference does not exist"

  Scenario: Empty author string (with separator)
    When I follow "New"
    And I fill in "reference_author_names_string" with " ; "
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"

  Scenario: Unparseable author string
    When I follow "New"
    And I fill in "reference_author_names_string" with "...asdf sdf dsfdsf"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
    And the "reference_author_names_string" field should contain "asdf"

  Scenario: Unparseable publisher string
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L"
    And I fill in "reference_title" with "A reference title"
    And I follow "Book"
    And I fill in "reference_publisher_string" with "Pensoft, Sophia"
    And I fill in "book_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Publisher string couldn't be parsed. In general, use the format 'Place: Publisher'."
    And I follow "Book"
    And the "reference_publisher_string" field should contain "Pensoft, Sophia"

  Scenario: Very long author string
    When I follow "New"
    And I fill in "reference_author_names_string" with a very long author names string
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see a very long author names string
