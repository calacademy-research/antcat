Feature: Edit reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Not logged in
    Given I am not logged in
      And the following entries exist in the bibliography
      |authors|citation  |cite_code|created_at|date    |possess|title|updated_at|year|
      |authors|Psyche 3:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      And I click the reference
    Then there should not be an edit form

  Scenario: Edit a reference
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|citation  |cite_code|created_at|date    |possess|title|updated_at|year|
      |authors|Psyche 5:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      Then I should not see the edit form
    When I click the reference
      Then I should see the edit form
      And I should not see the reference
    When I fill in "reference_authors_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "Ant Title"
      And I press the "Save" button
    Then I should be on the main page
      And I should see "Ward, B.L.; Bolton, B. 2010. Ant Title"

  Scenario: Inserting an author name into the middle of the list
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |cite_code|created_at|date    |possess|title|updated_at|year|
      |Ward, P.;Bolton, B.|Psyche 5:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      And I click the reference
    When I fill in "reference_authors_string" with "Ward, P.; Fisher, B.; Bolton, B."
      And I press the "Save" button
    Then I should see "Ward, P.; Fisher, B.; Bolton, B."

  Scenario: Change a reference's year
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation  |year|
      |Fisher, B.L. |Ants |Psyche 6:4|2010|
    When I go to the main page
      And I click the reference
      And I fill in "reference_citation_year" with "1910a"
      And I press the "Save" button
      And I fill in "q" with "1910"
      And I press "Search"
    Then I should see "Fisher, B.L. 1910a"

  Scenario: Change a reference's type
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation  |year|
      |Fisher, B. |Ants |Psyche 6:4|2010|
    When I go to the main page
      And I click the reference
      And I follow "Book"
      And I fill in "publisher_string" with "New York: Wiley"
      And I fill in "book_pagination" with "22 pp."
      And I press the "Save" button
    Then I should see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."

  Scenario: See the correct tab initially
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation               |year|
      |Fisher, B. |Ants |New York: Wiley, 22 pp.|2010|
    When I go to the main page
      And I click the reference
      And I fill in "publisher_string" with "New York: Harcourt"
      And I press the "Save" button
    Then I should see "Fisher, B. 2010. Ants. New York: Harcourt, 22 pp."

  Scenario: See the correct tab initially
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation|year|
      |Fisher, B. |Ants |New York|2010|
    When I go to the main page
      And I click the reference
      And I fill in "reference_citation" with "New Jersey"
      And I press the "Save" button
    Then I should see "Fisher, B. 2010. Ants. New Jersey."

  Scenario: Clearing a book reference's fields
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation               |year |title|
      |Ward, P.S. |New York: Wiley, 36 pp.|2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_authors_string" with ""
      And I fill in "reference_title" with ""
      And I fill in "reference_citation_year" with ""
      And I fill in "publisher_string" with ""
      And I fill in "book_pagination" with ""
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Publisher can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Clearing an article reference's fields
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |year |title|
      |Ward, P.S. |Psyche 1:2|2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_authors_string" with ""
      And I fill in "reference_title" with ""
      And I fill in "reference_citation_year" with ""
      And I fill in "journal_name" with ""
      And I fill in "reference_series_volume_issue" with ""
      And I fill in "article_pagination" with ""
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Title can't be blank"
      And I should see "Year can't be blank"
      And I should see "Journal can't be blank"
      And I should see "Series volume issue can't be blank"
      And I should see "Pagination can't be blank"

  Scenario: Clearing an unknown reference's fields
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |year |title|
      |Ward, P.S. |New York  |2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_authors_string" with ""
      And I fill in "reference_title" with ""
      And I fill in "reference_citation_year" with ""
      And I fill in "reference_citation" with ""
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Title can't be blank"
      And I should see "Year can't be blank"
      And I should see "Citation can't be blank"

  Scenario: Specifying the source URL
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |year |title|
      |Ward, P.S. |New York  |2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_source_url" with "google.com"
      And I press the "Save" button
    Then I should see a "PDF" link

  Scenario: Adding the authors' role
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |year |title|
      |Ward, P.S. |New York  |2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_authors_string" with "Ward, P.S. (ed.)"
      And I press the "Save" button
    Then I should see "Ward, P.S. (ed.)"

  Scenario: Removing the authors' role
    Given I am logged in
      And the following entries exist in the bibliography
      |authors         |citation  |year |title|
      |Ward, P.S. (ed.)|New York  |2010a|Ants |
    When I go to the main page
    Then I should see "Ward, P.S. (ed.)"
    When I click the reference
    When I fill in "reference_authors_string" with "Ward, P.S."
      And I press the "Save" button
    Then I should see "Ward, P.S."

  Scenario: Specifying the source URL when it doesn't exist
    Given I am logged in
      And the following entries exist in the bibliography
      |authors    |citation  |year |title|
      |Ward, P.S. |New York  |2010a|Ants |
    When I go to the main page
    When I click the reference
    When I fill in "reference_source_url" with "asdfsdfsdfsdfdsf.com"
      And I press the "Save" button
    Then I should see the edit form
      And I should see "Source url was not found"

  Scenario: Viewing a reference's id
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|citation  |cite_code|created_at|date    |possess|title|updated_at|year|
      |authors|Psyche 5:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      And I click the reference
    Then I should see the edit form
      And I should see the reference's ID beside its label

  Scenario: Edit a nested reference
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |citation  |year|title|
      |Ward, P.S.|Psyche 5:3|2001|Ants|
      And the following entry nests it
      |authors   |title           |year|pages_in|
      |Bolton, B.|Ants are my life|2001|In:|
    When I go to the main page
      Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3" 
    When I click the reference
      And I fill in "reference_pages_in" with "Pp. 32 in:"
      And I press the "Save" button
    Then I should see "Bolton, B. 2001. Ants are my life. Pp. 32 in: Ward, P.S. 2001. Ants. Psyche 5:3" 

  Scenario: Edit a nested reference and changing its nestee to itself
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |citation  |year|title|
      |Ward, P.S.|Psyche 5:3|2001|Ants|
      And the following entry nests it
      |authors   |title           |year|pages_in|
      |Bolton, B.|Ants are my life|2001|In:|
    When I go to the main page
      Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3" 
    When I click the reference
      And I fill in "reference_nested_reference_id" with its own ID
      And I press the "Save" button
    Then I should see "Nested reference can't point to itself"

