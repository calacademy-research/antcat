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
      And I press "OK"
    Then I should be on the main page
      And I should see "Ward, B.L.; Bolton, B. 2010. Ant Title"

  Scenario: Change a reference's year
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation  |year|
      |Fisher |Ants |Psyche 6:4|2010|
    When I go to the main page
      And I click the reference
      And I fill in "reference_citation_year" with "1910a"
      And I press "OK"
      And I fill in "start_year" with "1910"
      And I press "Search"
    Then I should see "Fisher 1910a"

  Scenario: Change a reference's type
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation  |year|
      |Fisher |Ants |Psyche 6:4|2010|
    When I go to the main page
      And I click the reference
      And I follow "Book"
      And I fill in "publisher_string" with "New York: Wiley"
      And I fill in "book_pagination" with "22 pp."
      And I press "OK"
    Then I should see "Fisher 2010. Ants. New York: Wiley, 22 pp."

  Scenario: See the correct tab initially
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation               |year|
      |Fisher |Ants |New York: Wiley, 22 pp.|2010|
    When I go to the main page
      And I click the reference
      And I fill in "publisher_string" with "New York: Harcourt"
      And I press "OK"
    Then I should see "Fisher 2010. Ants. New York: Harcourt, 22 pp."

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
      And I press "OK"
    Then I should see the edit form
      And I should see "Authors can't be blank"
      And I should see "Year can't be blank"
      And I should see "Title can't be blank"
      And I should see "Publisher can't be blank"
      And I should see "Pagination can't be blank"

