@javascript
Feature: Checking for duplicates during data entry
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references

  Background:
    Given I am logged in
    And this reference exists
      | authors  | citation   | title | year |
      | Ward, P. | Psyche 6:1 | Ants  | 2010 |

  Scenario: Adding a duplicate reference, but saving it anyway
    When I go to the references page
    And I follow "New"
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_series_volume_issue" with "6"
    And I fill in "reference_citation_year" with "2010"
    And I fill in "reference_journal_name" with "Psyche"
    And I fill in "article_pagination" with "1"
    And I press "Save"
    Then I should see "This may be a duplicate of Ward, P. 2010. Ants. Psyche 6:1"

    When I press "Save Anyway"
    Then I should see "Reference was successfully created"

  Scenario: Editing a reference that makes it a duplicate
    Given this reference exists
      | authors    | citation   | title            | year |
      | Bolton, B. | Psyche 5:3 | Ants are my life | 2010 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_series_volume_issue" with "6:1"
    And I press "Save"
    Then I should see "This may be a duplicate of Ward, P. 2010. Ants. Psyche 6:1"

    When I press "Save Anyway"
    Then I should see "Reference was successfully updated"
