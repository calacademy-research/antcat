Feature: Editing a taxon with authorization constraints
  Scenario: Trying to edit without being logged in
    Given there is a genus "Calyptites"

    When I go to the edit page for "Calyptites"
    Then I should be on the login page

  Scenario: Trying to edit without catalog editing rights
    Given there is a genus "Calyptites"
    And I log in as a user (not editor)

    When I go to the catalog page for "Calyptites"
    Then I should not see an Edit button
    And I should not see "Delete"

  Scenario: Trying to edit a taxon that's waiting for approval
    Given I log in as a catalog editor
    And there is a genus "Calyptites" that's waiting for approval

    When I go to the catalog page for "Calyptites"
    Then I should see an Edit button
    And I should see "Review change"

  Scenario: Seeing the delete button as superadmin
    Given there is a genus "Calyptites"
    And I log in as a superadmin

    When I go to the catalog page for "Calyptites"
    Then I should see "Delete..."
