Feature: Checking for duplicates during data entry
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references

  Background:
    Given I log in as a helper editor
    And this article reference exists
      | author   | title | year | series_volume_issue | pagination |
      | Ward, P. | Ants  | 2010 | 4                   | 9          |

  Scenario: Adding a duplicate reference, but saving it anyway
    When I go to the references page
    And I follow "New"
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_year" with "2010"
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_journal_name" with "Acta"
    And I fill in "reference_series_volume_issue" with "4"
    And I fill in "reference_pagination" with "9"
    And I press "Save"
    Then I should see "This may be a duplicate of Ward, 2010"

    When I press "Save"
    Then I should see "Reference was successfully added"

  Scenario: Editing a reference that makes it a duplicate
    Given there is an article reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with "Ward, P."
    And I fill in "reference_title" with "Ants"
    And I fill in "reference_year" with "2010"
    And I fill in "reference_journal_name" with "Acta"
    And I fill in "reference_series_volume_issue" with "4"
    And I press "Save"
    Then I should see "This may be a duplicate of Ward, 2010"

    When I press "Save"
    Then I should see "Reference was successfully updated"
