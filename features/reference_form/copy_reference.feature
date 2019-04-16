Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Background:
    Given I am logged in as a helper editor

  Scenario: Copy an article reference
    Given this reference exist
      | author     | title          | citation | citation_year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910          |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "Article" tab should be selected
    And the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_citation_year" field should contain "1910"
    And the "article_pagination" field should contain "2"
    And the "reference_journal_name" field should contain "Ants"
    And the "reference_series_volume_issue" field should contain "1"

  Scenario: Copy a book reference
    Given this book reference exist
      | author     | citation_year | citation                |
      | Bolton, B. | 2010          | New York: Wiley, 23 pp. |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "Book" tab should be selected
    And the "reference_author_names_string" field should contain "Bolton, B."
    And the "reference_citation_year" field should contain "2010"
    And the "book_pagination" field should contain "23 pp."
    And the "reference_publisher_string" field should contain "New York: Wiley"

  Scenario: Copy a nested reference
    Given there is an article reference
    And the following entry nests it
      | author       | title          | citation_year | pages_in |
      | Aardvark, A. | Dolichoderinae | 2011          | In:      |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "Nested" tab should be selected
    And the "reference_author_names_string" field should contain "Aardvark, A."
    And the "reference_citation_year" field should contain "2011"
    And the "reference_pages_in" field should contain "In:"
    And nesting_reference_id should contain a valid reference id

  Scenario: Copy an unknown reference
    Given this unknown reference exist
      | author     | citation | citation_year |
      | Ward, P.S. | New York | 2010a         |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "Other" tab should be selected
    And the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_citation_year" field should contain "2010a"
    And the "reference_citation" field should contain "New York"

  @javascript
  Scenario: Copy a reference with a document
    Given there is a reference
    And that the entry has a URL that's on our site
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "reference_document_attributes_url" field should contain ""
