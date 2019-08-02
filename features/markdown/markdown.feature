Feature: Markdown
  Background:
    Given I log in as a catalog editor

  Scenario: Using markdown
    Given there is an open issue "Merge 'Giovanni' authors"
    Given this reference exists
      | author       | citation_year |
      | Giovanni, S. | 1809          |

    When I go to the issue page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "issue_description" with "See:" and a markdown link to "Giovanni, 1809"
    And I press "Save"
    Then I should see "See: Giovanni, 1809"
