Feature: Not logged in
  Scenario: Latest Additions - Logged in, but not as a catalog editor
    Given I log in as a user (not editor)
    And this reference exists
      | authors  | citation   | title        |
      | Ward, P. | Psyche 5:3 | Ward's World |

    When I go to the latest reference additions page
    Then I should not see "Start reviewing"
