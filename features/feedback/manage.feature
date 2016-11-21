Feature: Managing user feedback
  As an AntCat editor
  I want to open/close user feedback items
  So that editors can track issues

  Background:
    Given I log in as a catalog editor

  Scenario: Closing a feedback item
    Given a visitor has submitted a feedback

    When I go to the most recent feedback item
    Then I should see "Status: open"
    And I should not see "Re-open"

    When I follow "Close"
    Then I should see "Successfully closed feedback item."
    And I should see "Re-open"
    And I should see "Status: closed"

  Scenario: Re-opening a closed feedback item
    Given there is a closed feedback item

    When I go to the most recent feedback item
    Then I should see "Re-open"
    And I should see "Status: closed"

    When I follow "Re-open"
    Then I should see "Successfully re-opened feedback item."
    And I should see "Status: open"
    And I should not see "Re-open"

  Scenario: Deleting a feedback item
    Given a visitor has submitted a feedback with the comment "buy r0lex spam"
    And I log in as a superadmin

    When I go to the most recent feedback item
    And I press "Delete"
    Then I should see "Feedback item was successfully deleted."

  Scenario: Only superadmins should be able to delete feedback
    Given a visitor has submitted a feedback

    When I go to the most recent feedback item
    Then I should not see "Delete"
