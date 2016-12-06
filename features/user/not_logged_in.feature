Feature: Not logged in
  Scenario: Latest Additions - Logged in, but not as a catalog editor
    Given I log in as a user (not editor)
    And there is a reference

    When I go to the latest reference additions page
    Then I should not see "Start reviewing"

  Scenario: Cannot edit references
    When I go to the references page
    Then I should not see "New"
