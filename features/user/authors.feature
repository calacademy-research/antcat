Feature: Working with authors and their names

  Background:
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And these references exist
      | authors    | title          | year | citation   |
      | Bolton, B. | Annals of Ants | 2010 | Psyche 1:1 |
      | Bolton,B.  | More ants      | 2011 | Psyche 2:2 |
    And the following names exist for another author
      | Fisher, B. |

  Scenario: Seeing all the authors with their names
    When I go to the authors page
    Then I should see "Bolton, B.; Bolton,B."
    And I should see "Fisher, B."
    When I click "edit" in the first row
    Then I should be on the author edit page for "Bolton, B."
