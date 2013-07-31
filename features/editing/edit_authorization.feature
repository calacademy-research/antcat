@javascript
Feature: Editing a taxon with authorization constraints

  Background:
    Given that version tracking is enabled

  Scenario: Trying to edit without being logged in
    Given there is a genus "Calyptites"
    When I go to the edit page for "Calyptites"
    And I should be on the login page

  Scenario: Trying to edit without catalog editing rights
    Given there is a genus "Calyptites"
    And I log in as a bibliography editor
    When I go to the catalog page for "Calyptites"
    Then I should not see "Edit"

  Scenario: Trying to edit a taxon that's waiting for approval
    Given there is a genus "Calyptites" that's waiting for approval
    And I log in as a catalog editor
    When I go to the catalog page for "Calyptites"
    Then I should not see "Edit"
    And I should see "Review change"

  @preview
  Scenario: Trying to edit without catalog editing rights on preview server
    Given there is a genus "Calyptites"
    When I go to the catalog page for "Calyptites"
    And I press "Edit"
    Then I should be on the edit page for "Calyptites"
