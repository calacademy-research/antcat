@dormant @javascript
Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Background:
    Given I am logged in
      And the following references exist
      |author    |title         |year|citation  |
      |Ward, P.S.|Annals of Ants|2010|Psyche 1:1|
      And I go to the references page

  Scenario: Not logged in
    When I log out
    And I go to the references page
    Then I should not see the "add" icon

  Scenario: Logged in
    Then I should see the "add" icon

  Scenario: Add a reference
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1992"
      And in the new edit form I press the "Save" button
    Then I should be on the references page
      And I should not be editing
      And I should see "Ward, B.L.; Bolton, B. 1992. Between Pacific Tides. Ants 2:1."

  @preview
  Scenario: Adding when not logged in, but in preview environment
    When I log out
    And I go to the references page
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1992"
      And in the new edit form I press the "Save" button
      And I should not be editing
      And I should see "Ward, B.L.; Bolton, B. 1992. Between Pacific Tides. Ants 2:1."

  Scenario: Adding a reference but then cancelling
    When I follow "add"
      And in the new edit form I fill in "reference_title" with "Mark Wilden"
      And in the new edit form I press the "Cancel" button
    Then there should be just the existing reference

  Scenario: Hide Delete button while adding
    When I follow "add"
    Then I should see a new edit form
      And the "Delete" button should not be visible

  Scenario: Adding a book
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Book"
      And in the new edit form I fill in "publisher_string" with "New York:Houghton Mifflin"
      And in the new edit form I fill in "book_pagination" with "32 pp."
      And in the new edit form I press the "Save" button
    Then I should be on the references page
      And I should not be editing
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."

  Scenario: Adding an article
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I fill in "journal_name" with "Ant Journal"
      And in the new edit form I fill in "reference_series_volume_issue" with "1"
      And in the new edit form I fill in "article_pagination" with "2"
      And in the new edit form I press the "Save" button
    Then I should be on the references page
      And I should not be editing
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Nested"
      And in the new edit form I fill in "reference_pages_in" with "Pp. 32-33 in:"
      And in the new edit form I fill in "reference_nested_reference_id" with the existing reference's ID
      And in the new edit form I press the "Save" button
      And I wait for a bit
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Adding an 'Other' reference
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Other"
      And in the new edit form I fill in "reference_citation" with "In Muller, Brown 1928. Ants. p. 23."
      And in the new edit form I press the "Save" button
    Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. In Muller, Brown 1928. Ants. p. 23."

  Scenario: Leaving other fields blank when adding an article reference
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Fisher, B.L."
      And in the new edit form I press the "Save" button
      And I wait for a bit
    Then I should see a new edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Journal can't be blank"
      And I should see "Series volume issue can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a book reference
    When I follow "add"
      And in the new edit form I follow "Book"
      And in the new edit form I fill in "reference_author_names_string" with "Fisher, B.L."
      And in the new edit form I press the "Save" button
    Then I should see a new edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Publisher can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a nested reference
    When I follow "add"
      And in the new edit form I follow "Nested"
      And in the new edit form I fill in "reference_author_names_string" with "Fisher, B.L."
      And in the new edit form I press the "Save" button
    Then I should see a new edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Pages in can't be blank"
      And I should see "Nested reference can't be blank"

  Scenario: Adding a reference with authors' role
    When I follow "add"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B. (eds.)"
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I fill in "journal_name" with "Ant Journal"
      And in the new edit form I fill in "reference_series_volume_issue" with "1"
      And in the new edit form I fill in "article_pagination" with "2"
      And in the new edit form I press the "Save" button
    Then I should be on the references page
      And I should see "Ward, B.L.; Bolton, B. (eds.) 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference with a nonexistent nestee
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Nested"
      And in the new edit form I fill in "reference_pages_in" with "Pp. 32-33 in:"
      And in the new edit form I fill in "reference_nested_reference_id" with "123123"
      And in the new edit form I press the "Save" button
      Then I should see "Nested reference does not exist"

  Scenario: Empty author string (with separator)
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with " ; "
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"

  Scenario: Unparseable author string
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "...asdf sdf dsfdsf"
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
      And in the new edit form the "reference_author_names_string" field should contain "asdf"

  Scenario: Unparseable publisher string
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L"
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I follow "Book"
      And in the new edit form I fill in "publisher_string" with "Pensoft, Sophia"
      And in the new edit form I fill in "book_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I press the "Save" button
    Then I should see "Publisher string couldn't be parsed. In general, use the format 'Place: Publisher'. Otherwise, please post a message on http://groups.google.com/group/antcat/, and we'll see what we can do!"
      And in the new edit form the "publisher_string" field should contain "Pensoft, Sophia"

  Scenario: Very long author string
    When I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with a very long author names string
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I press the "Save" button
      And I wait for a bit
    Then I should see a very long author names string

