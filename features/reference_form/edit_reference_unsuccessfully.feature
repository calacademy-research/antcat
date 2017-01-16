Feature: Edit reference unsuccessfully
  Background:
    Given I am logged in

  @javascript
  Scenario: Clearing a book reference's fields
    Given there is a book reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_publisher_string" with ""
    And I fill in "book_pagination" with ""
    And I press "Save"
    Then I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Publisher can't be blank"
    And I should see "Pagination can't be blank"

  @javascript
  Scenario: Clearing an article reference's fields
    Given there is an article reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_journal_name" with ""
    And I fill in "reference_series_volume_issue" with ""
    And I fill in "article_pagination" with ""
    And I press "Save"
    Then I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Journal can't be blank"
    And I should see "Series volume issue can't be blank"
    And I should see "Pagination can't be blank"

  @javascript
  Scenario: Clearing an unknown reference's fields
    Given there is an unknown reference

    When I go to the edit page for the most recent reference
    And I follow "Other"
    And I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_citation_year" with ""
    And I fill in "reference_citation" with ""
    And I press "Save"
    Then I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Citation can't be blank"

  @javascript
  Scenario: Specifying the document URL when it doesn't exist
    Given there is a reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_document_attributes_url" with a URL to a document that doesn't exist in the first reference
    And I press "Save"
    Then I should see "Document url was not found"

  @javascript
  Scenario: Edit a nested reference and changing its nestee to itself
    Given there is a reference
    And the following entry nests it
      | authors    | title            | year | pages_in |
      | Bolton, B. | Ants are my life | 2001 | In:      |

    When I go to the edit page for the most recent reference
    And I fill in "reference_nesting_reference_id" with its own ID
    And I press "Save"
    Then I should see "Nesting reference can't point to itself"

  #Scenario: Edit a nested reference to remove its nestedness, delete the nestee, go back to the first one and set it as nested
    #Given there is a reference
    #And the following entry nests it
      #| authors    | title            | year | pages_in |
      #| Bolton, B. | Ants are my life | 2001 | In:      |
    #When I go to the references page
    #And I edit "Bolton"
    #And I follow "Article" in the first reference
    #And I fill in "reference_journal_name" with "Ant Journal" in the first reference
    #And I fill in "reference_series_volume_issue" with "1" in the first reference
    #And I fill in "article_pagination" with "2" in the first reference
    #And I press "Save"
    #And I will confirm on the next step
    #And I delete "Ward"
    #And I edit "Bolton"
    #And I follow "Nested" in the first reference
    #And I press "Save"
    #Then I should see "nesting_reference can't be blank"

  @javascript
  Scenario: Cancelling edit after an error
    Given this reference exists
      | authors   | year | title                    | citation      |
      | Forel, A. | 1874 | Les fourmis de la Suisse | Neue 26:1-452 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_title" with ""
    And I press "Save"
    Then I should see "Title can't be blank"

    When I follow "Cancel"
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "

    When I follow "Edit"
    Then I should not see any error messages

    When I press "Save"
    Then I should not see any error messages
    And I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452 "
