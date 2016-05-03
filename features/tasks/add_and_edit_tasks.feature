Feature: Add and edit open tasks
  As an AntCat editor
  I want to add, edit and browse open tasks
  So that editors can help each other to improve the catalog

  Background:
    Given I am logged in

  Scenario: No open tasks
    When I go to the open tasks page
    Then I should see "There are currently no open tasks."

  Scenario: Adding a task
    When I go to the open tasks page
    And I follow "New"
    And I fill in "task_title" with "Resolve homonyms"
    And I fill in "task_description" with "Ids #999 and #777"
    And I press "Save"
    Then I should see "Successfully created task"

    When I go to the open tasks page
    Then I should see "Resolve homonyms"

  Scenario: Editing a task
    Given there is an open task "Restore deleted species"

    When I go to the open tasks page
    Then I should see the open task "Restore deleted species"

    When I follow "Restore deleted species"
    And I follow "Edit"
    And I fill in "task_title" with "Restore deleted genera"
    And I fill in "task_description" with "The genera: #7554, #8863"
    And I press "Save"
    Then I should see "Successfully updated task"
    And I should see "The genera: #7554, #8863"

    When I go to the open tasks page
    Then I should see "Restore deleted genera"
    And I should not see "Restore deleted species"

  Scenario: Completing a task
    Given there is an open task "Fix typo"
    When I go to the open tasks page
    Then I should see the open task "Fix typo"

    When I follow "Fix typo"
    And I follow "Complete"
    Then I should see "Successfully marked task as completed"

    When I go to the open tasks page
    Then I should see the completed task "Fix typo"

  Scenario: Re-opening a closed task
    Given there is a closed task "Add taxa from Aldous 2007"
    When I go to the open tasks page
    Then I should see "There are currently no open tasks."
    And I should see the closed task "Add taxa from Aldous 2007"

    When I follow "Add taxa from Aldous 2007"
    And I follow "Re-open"
    Then I should see "Successfully re-opened task"

    When I go to the open tasks page
    Then I should see the open task "Add taxa from Aldous 2007"

  Scenario: Using markdown
    Given there is an open task "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the task page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "task_description" with "Ref: %r7777"
    And I press "Save"
    Then I should see "Ref: Giovanni, 1809"

  @javascript
  Scenario: Previewing markdown
    Given there is an open task "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the task page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "task_description" with "Ref: %r7777"
    And I follow "Preview"
    Then I should see "Ref: Giovanni, 1809"
