Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Scenario: Not logged in
    Given I am not logged in
    When I go to the main page
      Then I should not see "Add reference"

  Scenario: Logged in
    When I log in
      And I go to the main page
      Then I should see "Add reference"

  Scenario: Add a reference when there are no others
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "journal_name" with "Ants"
      And I fill in "reference_series_volume_issue" with "2"
      And I fill in "article_pagination" with "1"
      And I fill in "reference_citation_year" with "1981"
      And I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ants 2:1."
      And "Add reference" should not be visible

  Scenario: Add but cancel a reference when there are no others
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_title" with "Mark Wilden"
      And I press "Cancel"
      And I should not see "Mark Wilden"

  Scenario: Add a reference when there are others
    Given I am logged in
      And the following references exist
      |author    |title         |year|citation  |
      |Ward, P.S.|Annals of Ants|2010|Psyche 1:1|
    When I go to the main page
      Then "Add reference" should not be visible
    When I follow "add"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
      And in the new edit form I fill in "journal_name" with "Ants"
      And in the new edit form I fill in "reference_series_volume_issue" with "2"
      And in the new edit form I fill in "article_pagination" with "1"
      And in the new edit form I fill in "reference_citation_year" with "1992"
      And in the new edit form I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1992. Between Pacific Tides. Ants 2:1."

  Scenario: Adding a reference but then cancelling
    Given I am logged in
      And the following references exist
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Psyche 2:2|year|
    When I go to the main page
    When I follow "add"
    When in the new edit form I fill in "reference_title" with "Mark Wilden"
      And in the new edit form I press the "Cancel" button
    Then there should be just the existing reference

  Scenario: Hide Delete button while adding
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
        And I should not see a "Delete" button

  Scenario: Adding a book
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I follow "Book"
      And I fill in "publisher_string" with "New York:Houghton Mifflin"
      And I fill in "book_pagination" with "32 pp."
      And I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."

  Scenario: Adding an article
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I fill in "journal_name" with "Ant Journal"
      And I fill in "reference_series_volume_issue" with "1"
      And I fill in "article_pagination" with "2"
      And I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference
    Given I am logged in
      And the following references exist
      |authors   |title         |year|citation|
      |Ward, P.S.|Annals of Ants|2010|Psyche 1:1|
    When I go to the main page
      And I follow "add"
    When in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Nested"
      And in the new edit form I fill in "reference_pages_in" with "Pp. 32-33 in:"
      And in the new edit form I fill in "reference_nested_reference_id" with the existing reference's ID
      And in the new edit form I press the "Save" button
      Then I should see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Adding another reference
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I follow "Other"
      And I fill in "reference_citation" with "In Muller, Brown 1928. Ants. p. 23."
      And I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title. In Muller, Brown 1928. Ants. p. 23."

  Scenario: Leaving other fields blank when adding an article reference
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      And I fill in "reference_author_names_string" with "Fisher, B.L."
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Journal can't be blank"
      And I should see "Series volume issue can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a book reference
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      And I follow "Book"
      And I fill in "reference_author_names_string" with "Fisher, B.L."
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Publisher can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Leaving other fields blank when adding a nested reference
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      And I follow "Nested"
      And I fill in "reference_author_names_string" with "Fisher, B.L."
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Pages in can't be blank"
      And I should see "Nested reference can't be blank"

  Scenario: Adding a reference with authors' role
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B. (eds.)"
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I fill in "journal_name" with "Ant Journal"
      And I fill in "reference_series_volume_issue" with "1"
      And I fill in "article_pagination" with "2"
      And I press the "Save" button
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. (eds.) 1981. A reference title. Ant Journal 1:2"

  Scenario: Adding a nested reference with a nonexistent nestee
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
    When in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "A reference title"
      And in the new edit form I fill in "reference_citation_year" with "1981"
      And in the new edit form I follow "Nested"
      And in the new edit form I fill in "reference_pages_in" with "Pp. 32-33 in:"
      And in the new edit form I fill in "reference_nested_reference_id" with "123123"
      And in the new edit form I press the "Save" button
      Then I should see "Nested reference does not exist"

  Scenario: Empty author string (with separator)
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_author_names_string" with " ; "
      And I fill in "reference_title" with "A reference title"
      And I fill in "journal_name" with "Ants"
      And I fill in "reference_series_volume_issue" with "2"
      And I fill in "article_pagination" with "1"
      And I fill in "reference_citation_year" with "1981"
      And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"


  Scenario: Unparseable author string
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_author_names_string" with "Feitosa, R dos S. M."
      And I fill in "reference_title" with "A reference title"
      And I fill in "journal_name" with "Ants"
      And I fill in "reference_series_volume_issue" with "2"
      And I fill in "article_pagination" with "1"
      And I fill in "reference_citation_year" with "1981"
      And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"

