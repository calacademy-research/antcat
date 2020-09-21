Feature: Manage names
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Editing a name (with edit summary)
    Given there is a genus protonym "Formica"

    When I go to the edit page for the protonym "Formica"
    And I follow "Name record"
    Then I should see "Name record: Formica"

    When I follow "Edit"
    Then I should see "Formica"
    And I should not see "Similar names"
    And I should not see "Formicus"

    When I fill in "name_name_string" with "Lasius"
    And I fill in "edit_summary" with "fix name"
    And I press "Save"
    Then I should see "Successfully updated name."
    And I should see "Name record: Lasius"

    When I go to the activity feed
    Then I should see "Archibald edited the name Lasius" within the activity feed
    And I should see the edit summary "fix name"

  @javascript
  Scenario: Checking for name conflicts
    Given there is a genus protonym "Formica"
    And there is a genus protonym "Formica"
    And there is a genus protonym "Formicus"

    When I go to the protonyms page
    And I follow the first "Formica"
    And I follow "Name record"
    And I follow "Edit"
    Then I should not see "Similar names"
    And I should not see "Formica (protonym)"
    And I should not see "Formicus (protonym)"

    When I fill in "name_name_string" with "formi"
    Then I should see "Similar names"
    And I should see "Formica (protonym)"
    And I should see "Formicus (protonym)"

    When I fill in "name_name_string" with "formica"
    Then I should see "Homonym Formica (protonym)"
