Feature: Editing a taxon with authorization constraints
  Scenario: Trying to edit without being logged in
    Given there is a genus "Calyptites"

    When I go to the edit page for "Calyptites"
    Then I should be on the login page
