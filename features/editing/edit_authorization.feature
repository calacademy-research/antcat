@javascript
Feature: Editing a taxon with authorization constraints

  Background:
    Given the Formicidae family exists
    Given that version tracking is enabled

  Scenario: Trying to edit without being logged in
    Given there is a genus "Calyptites"
    When I go to the edit page for "Calyptites"
    And I should be on the login page

  Scenario: Trying to edit without catalog editing rights
    Given there is a genus "Calyptites"
    And I log in as a bibliography editor
    When I go to the catalog page for "Calyptites"
    Then I should not see a "Edit" button
    And I should not see a "Delete" button

  Scenario: Trying to edit a taxon that's waiting for approval
    Given there is a genus "Calyptites" that's waiting for approval
    And I log in as a catalog editor
    When I go to the catalog page for "Calyptites"
    Then I should see an "Edit" button
    And I should see "Review change"
    And I should not see a "Delete" button

  Scenario: Seeing the delete button as superadmin
    Given there is a genus "Calyptites"
    And I log in as a superadmin
    When I go to the catalog page for "Calyptites"
    Then I should see an "Edit" button
    And I should see a "Delete" button

  Scenario: Trying to edit a taxon that's waiting for approval
    Given there is a genus "Calyptites" that's waiting for approval
    And I log in as a catalog editor
    When I go to the catalog page for "Calyptites"
    Then I should see an "Edit" button
    And I should see "Review change"
