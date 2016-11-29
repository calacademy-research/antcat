Feature: Edit reference unsuccessfully
  Scenario: Not logged in
    Given I am not logged in

    When I go to the references page
    Then I should not see "New"

  @javascript
  Scenario: Clearing a book reference's fields
    Given I am logged in
    And these book references exist
      | authors    | citation                | year | citation_year | title |
      | Aho, P.S.  | New York: Wiley, 36 pp. | 2010 | 2010a         | Ants  |

    When I go to the references page
    And I follow first reference link
    And I follow "Edit"
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_publisher_string" with ""
    And I fill in "book_pagination" with ""
    And I press the "Save" button
    Then I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Publisher can't be blank"
    And I should see "Pagination can't be blank"

  @javascript
  Scenario: Clearing an article reference's fields
    Given I am logged in
    And these references exist
      | authors    | citation   | year | citation_year | title |
      | Aho, P.S.  | Psyche 1:2 | 2010 | 2010a         | Ants  |

    When I go to the references page
    And I follow first reference link
    And I follow "Edit"
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_journal_name" with ""
    And I fill in "reference_series_volume_issue" with ""
    And I fill in "article_pagination" with ""
    And I press the "Save" button
    Then I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Journal can't be blank"
    And I should see "Series volume issue can't be blank"
    And I should see "Pagination can't be blank"

  @javascript
  Scenario: Clearing an unknown reference's fields
    Given I am logged in
    And these unknown references exist
      | authors   | citation | year | citation_year | title |
      | Aho, P.S. | New York | 2010 | 2010a         | Ants  |

    When I go to the references page
    And I follow first reference link
    And I follow "Edit"
    And I follow "Other"
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_citation" with ""
    And I press the "Save" button
    Then I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Citation can't be blank"

  @javascript
  Scenario: Specifying the document URL when it doesn't exist
    Given I am logged in
    And these references exist
      | authors    | citation   | year | citation_year | title |
      | Ward, P.S. | Psyche 1:1 | 2010 | 2010a         | Ants  |

    When I go to the references page
    And I follow first reference link
    And I follow "Edit"
    And I fill in "reference_document_attributes_url" with a URL to a document that doesn't exist in the first reference
    And I press the "Save" button
    Then I should see "Document url was not found"

  @javascript
  Scenario: Edit a nested reference and changing its nestee to itself
    Given I am logged in
    And these references exist
      | authors    | citation   | year | title |
      | Ward, P.S. | Psyche 5:3 | 2001 | Ants  |
    And the following entry nests it
      | authors    | title            | year | pages_in |
      | Bolton, B. | Ants are my life | 2001 | In:      |

    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"

    When I follow first reference link
    And I follow "Edit"
    And I fill in "reference_nesting_reference_id" with its own ID
    And I press the "Save" button
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
    #And I press the "Save" button
    #And I will confirm on the next step
    #And I delete "Ward"
    #And I edit "Bolton"
    #And I follow "Nested" in the first reference
    #And I press the "Save" button
    #Then I should see "nesting_reference can't be blank"

  @javascript
  Scenario: Cancelling edit after an error
    Given I am logged in
    And there are no references
    And this reference exists
      | authors   | year | title                    | citation      |
      | Forel, A. | 1874 | Les fourmis de la Suisse | Neue 26:1-452 |

    When I go to the references page
    And I follow first reference link
    And I follow "Edit"
    And I fill in "reference_title" with ""
    And I press the "Save" button
    Then I should see "Title can't be blank"

    When I press "Cancel"
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "

    When I follow "Edit"
    Then I should not see any error messages

    When I press the "Save" button
    Then I should not see any error messages
    And I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "
