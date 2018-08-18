Feature: Add reference unsuccessfully
  Background:
    Given I am logged in
    And I go to the references page
    And I follow "New"

  Scenario: Adding a reference but then cancelling
    When I fill in "reference_title" with "Mark Wilden"
    And I follow "Cancel"
    Then I should be on the references page

  Scenario: Leaving a required field blank should not affect other fields (article)
    When I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "article_pagination" with "2"
    And I press "Save"
    Then the "reference_title" field should contain "A reference title"

    When I follow "Article"
    Then the "reference_journal_name" field should contain "Ant Journal"
    And the "article_pagination" field should contain "2"

  @javascript
  Scenario: Leaving a required field blank should not affect other fields (book)
    When I follow "Book"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_publisher_string" with "Capua: House of Batiatus"
    And I fill in "book_pagination" with "2"
    And I press "Save"
    Then the "reference_title" field should contain "A reference title"

    When I follow "Book"
    Then the "reference_publisher_string" field should contain "Capua: House of Batiatus"
    And the "book_pagination" field should contain "2"

  @javascript
  Scenario: Adding a nested reference with a nonexistent nestee
    When I follow "Nested"
    And I fill in "reference_nesting_reference_id" with "123123"
    And I press "Save"
    Then I should see "Nesting reference does not exist"

  Scenario: Unparseable author string (and maintain already filled in fields)
    When I fill in "reference_author_names_string" with "...asdf sdf dsfdsf"
    And I press "Save"
    Then I should see "Author names string couldn't be parsed."
    And the "reference_author_names_string" field should contain "asdf"

  @javascript
  Scenario: Unparseable (blank) journal name (and maintain already filled in fields)
    When I fill in "reference_title" with "A reference title"
    And I follow "Article"
    And I fill in "reference_journal_name" with ""
    And I fill in "article_pagination" with "1"
    And I press "Save"
    Then I should see "Journal can't be blank"
    And the "reference_title" field should contain "A reference title"

    When I follow "Article"
    Then the "reference_journal_name" field should contain ""
    And the "article_pagination" field should contain "1"

  @javascript
  Scenario: Unparseable publisher string (and maintain already filled in fields)
    When I fill in "reference_title" with "A reference title"
    And I follow "Book"
    And I fill in "reference_publisher_string" with "Pensoft, Sophia"
    And I fill in "book_pagination" with "1"
    And I press "Save"
    Then I should see "Publisher string couldn't be parsed. In general, use the format 'Place: Publisher'."

    When I follow "Book"
    Then the "reference_title" field should contain "A reference title"
    And the "reference_publisher_string" field should contain "Pensoft, Sophia"
    And the "book_pagination" field should contain "1"
