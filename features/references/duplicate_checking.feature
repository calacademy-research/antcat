@dormant @javascript
Feature: Checking for duplicates during data entry
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references

  Scenario: Adding a duplicate reference, but saving it anyway
    Given these references exist
      | authors   | citation  | title | year |
      | Ward, P.  | Psyche 6:1| Ants  | 2010 |
    Given I am logged in
    When I go to the references page
    And I follow "add"
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_series_volume_issue" with "6"
    And I fill in "reference_citation_year" with "2010"
    And I fill in "reference_journal_name" with "Psyche"
    And I fill in "article_pagination" with "1"
    And I press the "Save" button
    And I should see "This may be a duplicate of Ward, P. 2010. Ants. Psyche 6:1."
    When I press "Save Anyway"
