Feature: Checking for duplicates during data entry
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references

  Scenario: Adding a duplicate reference
    Given the following references exist
      |authors   |citation  |title           |year|id|
      |Bolton, B.|Psyche 5:3|Ants are my life|2010|1 |
      |Ward, P.  |Psyche 6:1|Ants            |2010|2 |
      And I am logged in
    When I go to the main page
      And I follow "add"
      And in the new edit form I fill in "reference_author_names_string" with "Bolton, B."
      And in the new edit form I fill in "reference_title" with "Ants are my life"
      And in the new edit form I fill in "journal_name" with "Psyche"
      And in the new edit form I fill in "reference_citation_year" with "2010"
      And in the new edit form I press the "Save" button
    Then I should see the new edit form
    And I should see "This seems to be a duplicate of Bolton, B. 2010. Ants are my life. Psyche 5:3. 1"

  Scenario: Editing a reference that makes it a duplicate
    Given the following references exist
      |authors   |citation  |title           |year|id|
      |Bolton, B.|Psyche 5:3|Ants are my life|2010|1 |
      |Ward, P.  |Psyche 6:1|Ants            |2010|2 |
      And I am logged in
    When I go to the main page
      And I fill in "q" with "Bolton"
      And I press "Go"
      And I follow "edit"
      And I fill in "reference_author_names_string" with "Ward, P."
      And I fill in "reference_title" with "Ants"
      And I fill in "reference_series_volume_issue" with "6:1"
      And I press the "Save" button
    Then I should see the edit form
    And I should see "This seems to be a duplicate of Ward, P. 2010. Ants. Psyche 6:1. 2"
