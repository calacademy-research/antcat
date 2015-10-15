@dormant @javascript
Feature: Edit reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Not logged in
    Given I am not logged in
    And these dated references exist
      | authors | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | authors | Psyche 3:3 | CiteCode  | TODAYS_DATE      | 20100712 | Possess | title | TODAYS_DATE      | 2010 |
    When I go to the references page
    Then there should not be an edit form

  Scenario: Edit a reference
    Given these dated references exist
      | authors | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | authors | Psyche 5:3 | CiteCode  | TODAYS_DATE      | 20100712 | Possess | title | TODAYS_DATE      | 2010 |
    When I log in
    And I go to the references page
    And I should not be editing
    When I follow "edit" in the first reference
    Then I should see the edit form
    # TODO: Rails 4 upgrade hosed this. Verified manually.
#    And I should not see the reference
    When I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B." in the first reference
    And I fill in "reference_title" with "Ant Title" in the first reference
    And I save my changes to the first reference
    Then I should be on the references page
    And I should see "Ward, B.L.; Bolton, B. 2010. Ant Title"

  @preview
  Scenario: Edit a reference in the preview environment
    Given these dated references exist
      | authors | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | authors | Psyche 5:3 | CiteCode  | TODAYS_DATE      | 20100712 | Possess | title | TODAYS_DATE      | 2010 |
    Given I am not logged in
    When I go to the references page
    * I follow "edit" in the first reference
    * I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B." in the first reference
    * I fill in "reference_title" with "Ant Title" in the first reference
    * I save my changes to the first reference
    Then I should be on the references page
    And I should see "Ward, B.L.; Bolton, B. 2010. Ant Title"

  Scenario: Inserting an author name into the middle of the list
    Given I am logged in
    And these dated references exist
      | authors             | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | Ward, P.;Bolton, B. | Psyche 5:3 | CiteCode  | TODAYS_DATE      | 20100712 | Possess | title | TODAYS_DATE      | 2010 |
    When I go to the references page
    When I click the "edit" link beside the reference
    When in the edit form I fill in "reference_author_names_string" with "Ward, P.; Fisher, B.; Bolton, B."
    And In the edit form, I press the "Save" button
    Then I should see "Ward, P.; Fisher, B.; Bolton, B."

  Scenario: Change a reference's year
    Given I am logged in
    And these dated references exist
      | authors      | title | citation   | year | created_at | updated_at |
      | Aho, B.L.    | Ants  | Psyche 6:4 | 2010 | TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    And I fill in "reference_citation_year" with "1910a" in the first reference
    And I save my changes to the first reference
    Then I should see "Aho, B.L. 1910a"

  Scenario: Change a reference's type
    Given I am logged in
    And these dated references exist
      | authors    | title | citation   | year |  created_at | updated_at |
      | Fisher, B. | Ants  | Psyche 6:4 | 2010 | TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    And I follow "Book" in the first reference
    And I fill in "reference_publisher_string" with "New York: Wiley" in the first reference
    And I fill in "book_pagination" with "22 pp." in the first reference
    And I save my changes to the first reference
    Then I should see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."

  Scenario: See the correct tab initially
    Given I am logged in
    And these book references exist
      | authors    | title | citation                | year |
      | Fisher, B. | Ants  | New York: Wiley, 22 pp. | 2010 |
    When I go to the references page
    When I follow "edit" in the first reference
    And I fill in "reference_publisher_string" with "New York: Harcourt" in the first reference
    And I save my changes to the first reference
    Then I should see "Fisher, B. 2010. Ants. New York: Harcourt, 22 pp."

  Scenario: See the correct tab initially
    Given I am logged in
    And this unknown reference exists
      | authors    | title | citation | year |
      | Fisher, B. | Ants  | New York | 2010 |
    When I go to the references page
    When I follow "edit" in the first reference
    And I fill in "reference_citation" with "New Jersey" in the first reference
    And I save my changes to the first reference
    Then I should see "Fisher, B. 2010. Ants. New Jersey."

  Scenario: Clearing a book reference's fields
    Given I am logged in
    And these book references exist
      | authors    | citation                | year  | title |
      | Aho, P.S.  | New York: Wiley, 36 pp. | 2010a | Ants   |
    When I go to the references page
    When I follow "edit" in the first reference
    When I fill in "reference_author_names_string" with "" in the first reference
    And I fill in "reference_title" with "" in the first reference
    And I fill in "reference_citation_year" with "" in the first reference
    And I fill in "reference_publisher_string" with "" in the first reference
    And I fill in "book_pagination" with "" in the first reference
    And I save my changes to the first reference
    Then I should see the edit form
    And I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Publisher can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Clearing an article reference's fields
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year  | title | created_at | updated_at |
      | Aho, P.S.  | Psyche 1:2 | 2010a | Ants  |   TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    When I fill in "reference_author_names_string" with "" in the first reference
    And I fill in "reference_title" with "" in the first reference
    And I fill in "reference_citation_year" with "" in the first reference
    And I fill in "reference_journal_name" with "" in the first reference
    And I fill in "reference_series_volume_issue" with "" in the first reference
    And I fill in "article_pagination" with "" in the first reference
    And I save my changes to the first reference
    Then I should see the edit form
    And I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Journal can't be blank"
    And I should see "Series volume issue can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Clearing an unknown reference's fields
    Given I am logged in
    And these unknown references exist
      | authors    | citation | year  | title |
      | Aho, P.S. | New York | 2010a | Ants     |
    When I go to the references page
    When I follow "edit" in the first reference
    And I follow "Other"
    When I fill in "reference_author_names_string" with "" in the first reference
    And I fill in "reference_title" with "" in the first reference
    And I fill in "reference_citation_year" with "" in the first reference
    And I fill in "reference_citation" with "" in the first reference
    And I save my changes to the first reference
    Then I should see the edit form
    And I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Citation can't be blank"

  Scenario: Specifying the document URL
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year  | title | created_at | updated_at |
      | Ward, P.S. | Psyche 1:1 | 2010a | Ants  |  TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    And I fill in "reference_document_attributes_url" with a URL to a document that exists
    And I save my changes to the first reference
    Then I should see a "PDF" link

  #Scenario: Setting a document's publicness
    #Given these references exist
      #| authors    | year  | title     | citation |
      #| Ward, P.S. | 2010d | Ant Facts | Ants 1:1 |
    #And that the entry has a URL that's on our site
    #When I go to the references page
    #Then I should see a "PDF" link
    #When I log in
    #And I go to the references page
    #And I follow "edit" in the first reference
    #And I check "reference_document_attributes_public" in the first reference
    #And I save my changes to the first reference
    #And I log out
    #And I go to the references page
    #Then I should see a "PDF" link

  Scenario: Adding the authors' role
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year  | title | created_at | updated_at |
      | Ward, P.S. | Psyche 1:1 | 2010a | Ants  |  TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    When I fill in "reference_author_names_string" with "Ward, P.S. (ed.)" in the first reference
    And I save my changes to the first reference
    Then I should see "Ward, P.S. (ed.)"

  Scenario: Removing the authors' role
    Given I am logged in
    And these dated references exist
      | authors          | citation   | year  | title | created_at | updated_at |
      | Ward, P.S. (ed.) | Psyche 1:1 | 2010a | Ants  |  TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    Then I should see "Ward, P.S. (ed.)"
    When I follow "edit" in the first reference
    When I fill in "reference_author_names_string" with "Ward, P.S." in the first reference
    And I save my changes to the first reference
    Then I should see "Ward, P.S."

  Scenario: Specifying the document URL when it doesn't exist
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year  | title | created_at | updated_at |
      | Ward, P.S. | Psyche 1:1 | 2010a | Ants  |  TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    When I follow "edit" in the first reference
    When I fill in "reference_document_attributes_url" with a URL to a document that doesn't exist in the first reference
    And I save my changes to the first reference
    Then I should see the edit form
    And I should see "Document url was not found"

  Scenario: Viewing a reference's id
    Given I am logged in
    And these dated references exist
      | authors | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | authors | Psyche 5:3 | CiteCode  | TODAYS_DATE      | 20100712 | Possess | title | TODAYS_DATE      | 2010 |
    When I go to the references page
    When I follow "edit" in the first reference
    Then I should see the edit form
    And I should see the reference's ID beside its label

  Scenario: Edit a nested reference
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year | title |  created_at | updated_at |
      | Ward, P.S. | Psyche 5:3 | 2001 | Ants  |   TODAYS_DATE | TODAYS_DATE |
    And the following entry nests it
      | authors    | title            | year | pages_in | created_at | updated_at |
      | Bolton, B. | Ants are my life | 2001 | In:      |   TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"
    When I follow "edit" in the first reference
    And I fill in "reference_pages_in" with "Pp. 32 in:" in the first reference
    And I save my changes to the first reference
    Then I should see "Bolton, B. 2001. Ants are my life. Pp. 32 in: Ward, P.S. 2001. Ants. Psyche 5:3"

  Scenario: Edit a nested reference and changing its nestee to itself
    Given I am logged in
    And these dated references exist
      | authors    | citation   | year | title | created_at | updated_at |
      | Ward, P.S. | Psyche 5:3 | 2001 | Ants  |  TODAYS_DATE | TODAYS_DATE |
    And the following entry nests it
      | authors    | title            | year | pages_in | created_at | updated_at |
      | Bolton, B. | Ants are my life | 2001 | In:      |  TODAYS_DATE | TODAYS_DATE |
    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"
    When I follow "edit" in the first reference
    And I fill in "reference_nesting_reference_id" with its own ID
    And I save my changes to the first reference
    Then I should see "Nesting reference can't point to itself"

  #Scenario: Edit a nested reference to remove its nestedness, delete the nestee, go back to the first one and set it as nested
    #Given I am logged in
    #And these references exist
      #| authors    | citation   | year | title |
      #| Ward, P.S. | Psyche 5:3 | 2001 | Ants  |
    #And the following entry nests it
      #| authors    | title            | year | pages_in |
      #| Bolton, B. | Ants are my life | 2001 | In:      |
    #When I go to the references page
    #And I edit "Bolton"
    #And I follow "Article" in the first reference
    #And I fill in "reference_journal_name" with "Ant Journal" in the first reference
    #And I fill in "reference_series_volume_issue" with "1" in the first reference
    #And I fill in "article_pagination" with "2" in the first reference
    #And I save my changes to the first reference
    #And I will confirm on the next step
    #And I delete "Ward"
    #And I edit "Bolton"
    #And I follow "Nested" in the first reference
    #And I save my changes to the first reference
    #Then I should see "nesting_reference can't be blank"

  Scenario: Cancelling edit after an error
    Given I am logged in
    And there are no references
    And this dated reference exists
      | authors   | year | title                    | citation      | created_at | updated_at |
      | Forel, A. | 1874 | Les fourmis de la Suisse | Neue 26:1-452 |  TODAYS_DATE | TODAYS_DATE |
    And I go to the references page
    And I follow "edit"
    And I fill in "reference_title" with ""
    And I press the "Save" button
    Then I should see "Title can't be blank"
    When I press the "Cancel" button
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "
    When I follow "edit"
    Then I should not see any error messages
    When I press the "Save" button
    Then I should not see any error messages
    And I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "

