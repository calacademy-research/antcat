@javascript
Feature: Working with reference changes

  Background: 
    Given I am logged in
    And we are tracking changes
    And this reference exists
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |

  Scenario: Adding a reference and seeing the change
    When I go to the changes page
    Then I should not see "Between Pacific Tides"
    When I go to the references page
    When I follow "add" in the first reference
    And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
    And in the new edit form I fill in "reference_journal_name" with "Ants"
    And in the new edit form I fill in "reference_series_volume_issue" with "2"
    And in the new edit form I fill in "article_pagination" with "1"
    And in the new edit form I fill in "reference_citation_year" with "1992"
    And in the new edit form I press the "Save" button
    And I go to the changes page
    Then I should see "Between Pacific Tides"
