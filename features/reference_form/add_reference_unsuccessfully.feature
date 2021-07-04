Feature: Add reference unsuccessfully
  Background:
    Given I log in as a helper editor
    And I go to the references page
    And I follow "New"

  Scenario: Leaving required fields blank (general fields)
    When I fill in "reference_author_names_string" with ""
    And I fill in "reference_title" with ""
    And I fill in "reference_year" with ""
    And I fill in "reference_pagination" with ""
    And I press "Save"
    Then I should see "Author names can't be blank"
    And I should see "Title can't be blank"
    And I should see "Year can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Leaving required fields blank (`ArticleReference`)
    When I fill in "reference_journal_name" with ""
    And I fill in "reference_series_volume_issue" with ""
    And I press "Save"
    Then I should see "Journal: Name can't be blank"
    And I should see "Series volume issue can't be blank"

  Scenario: Leaving required fields blank (`BookReference`)
    When I select the reference tab "#book-tab"
    And I fill in "reference_publisher_string" with ""
    And I press "Save"
    Then I should see "Publisher string couldn't be parsed"

  Scenario: Leaving a required field blank should not affect other fields (`ArticleReference`)
    When I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_pagination" with "2"
    And I press "Save"
    Then I should see "Year can't be blank"
    And the "reference_title" field should contain "A reference title"

    When I select the reference tab "#article-tab"
    Then the "reference_journal_name" field should contain "Ant Journal"
    And the "reference_pagination" field should contain "2"

  Scenario: Leaving a required field blank should not affect other fields (`BookReference`)
    When I select the reference tab "#book-tab"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_publisher_string" with "Capua: House of Batiatus"
    And I fill in "reference_pagination" with "2"
    And I press "Save"
    Then the "reference_title" field should contain "A reference title"

    When I select the reference tab "#book-tab"
    Then the "reference_publisher_string" field should contain "Capua: House of Batiatus"
    And the "reference_pagination" field should contain "2"

  Scenario: Invalid author name (and maintain already filled in fields and correcting)
    When I fill in "reference_author_names_string" with "Bolton, B., Pizza; Fisher, B.; "
    And I press "Save"
    Then I should see "Author names (Bolton, B., Pizza): Name can only contain a single comma"
    And the "reference_author_names_string" field should contain "Bolton, B., Pizza; Fisher, B.; "

    When I fill in "reference_author_names_string" with "Bolton, B.P.; Fisher, B.; "
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_year" with "1981"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "reference_series_volume_issue" with "1"
    And I fill in "reference_pagination" with "2"
    And I press "Save"
    Then I should see "Bolton, B.P.; Fisher, B. 1981. A reference title. Ant Journal 1:2"

  Scenario: Invalid author name
    When I fill in "reference_author_names_string" with "A"
    And I press "Save"
    Then I should see "Author names (A): Name is too short (minimum is 2 characters)"
    And the "reference_author_names_string" field should contain "A"

  Scenario: Unparseable (blank) journal name (and maintain already filled in fields)
    When I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with ""
    And I fill in "reference_pagination" with "1"
    And I press "Save"
    Then I should see "Journal: Name can't be blank"
    And the "reference_title" field should contain "A reference title"

    When I select the reference tab "#article-tab"
    Then the "reference_journal_name" field should contain ""
    And the "reference_pagination" field should contain "1"

  Scenario: Unparseable publisher string (and maintain already filled in fields)
    When I fill in "reference_title" with "A reference title"
    And I select the reference tab "#book-tab"
    And I fill in "reference_publisher_string" with "Pensoft, Sophia"
    And I fill in "reference_pagination" with "1"
    And I press "Save"
    Then I should see "Publisher string couldn't be parsed. Expected format 'Place: Publisher'."

    When I select the reference tab "#book-tab"
    Then the "reference_title" field should contain "A reference title"
    And the "reference_publisher_string" field should contain "Pensoft, Sophia"
    And the "reference_pagination" field should contain "1"
