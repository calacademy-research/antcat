@dormant @javascript
Feature: Checking for duplicates during data entry
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references

  Scenario: Adding a duplicate reference
    Given the following references exist
      | authors    | citation   | title            | year |
      | Bolton, B. | Psyche 5:3 | Ants are my life | 2010 |
      | Ward, P.   | Psyche 6:1 | Ants             | 2010 |
    And I am logged in
    When I go to the references page
    And I follow "add"
    And in the new edit form I fill in "reference_author_names_string" with "Bolton, B."
    And in the new edit form I fill in "reference_title" with "Ants are my life"
    And in the new edit form I fill in "journal_name" with "Psyche"
    And in the new edit form I fill in "reference_citation_year" with "2010"
    And in the new edit form I press the "Save" button
    Then I should see a new edit form
    And I should see "This may be a duplicate of Bolton, B. 2010. Ants are my life. Psyche 5:3."

  Scenario: Adding a duplicate reference, but saving it anyway
    Given the following references exist
      | authors    | citation   | title            | year | id |
      | Bolton, B. | Psyche 5:3 | Ants are my life | 2010 | 1  |
      | Ward, P.   | Psyche 6:1 | Ants             | 2010 | 2  |
    And I am logged in
    When I go to the references page
    And I follow "add"
    And in the new edit form I fill in "reference_author_names_string" with "Bolton, B."
    And in the new edit form I fill in "reference_title" with "Ants are my life"
    And in the new edit form I fill in "journal_name" with "Psyche"
    And in the new edit form I fill in "reference_series_volume_issue" with "5"
    And in the new edit form I fill in "article_pagination" with "3"
    And in the new edit form I fill in "reference_citation_year" with "2010a"
    And in the new edit form I press the "Save" button
    Then I should see a new edit form
    And I should see "This may be a duplicate of Bolton, B. 2010. Ants are my life. Psyche 5:3."
    When I press the "Save Anyway" button
    Then I should be on the references page
    And I should not be editing
    And I should see "Bolton, B. 2010a. Ants are my life. Psyche 5:3."
    And I should see "Bolton, B. 2010. Ants are my life. Psyche 5:3."

  Scenario: Editing a reference that makes it a duplicate
    Given the following references exist
      | authors    | citation   | title            | year |
      | Bolton, B. | Psyche 5:3 | Ants are my life | 2010 |
      | Ward, P.   | Psyche 6:1 | Ants             | 2010 |
    And I am logged in
    When I go to the references page
    And I fill in the search box with "Bolton"
    And I press "Go" by the search box
    And I follow "edit"
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_series_volume_issue" with "6:1"
    And I press the "Save" button
    Then I should see the edit form
    And I should see "This may be a duplicate of Ward, P. 2010. Ants. Psyche 6:1."

