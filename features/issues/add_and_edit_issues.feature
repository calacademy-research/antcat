Feature: Add and edit open issues
  As an AntCat editor
  I want to add, edit and browse open issues
  So that editors can help each other to improve the catalog

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Adding an issue (with feed)
    When I go to the open issues page
    Then I should see "There are currently no open issues."

    When I follow "New"
    And I fill in "issue_title" with "Resolve homonyms"
    And I fill in "issue_description" with "Ids #999 and #777"
    And I fill in "edit_summary" with "added question"
    And I press "Save"
    Then I should see "Successfully created issue"

    When I go to the open issues page
    Then I should see "Resolve homonyms"

    And I go to the activity feed
    Then I should see "Archibald added the issue Resolve homonyms" within the activity feed
    And I should see "added question"

  Scenario: Editing an issue (with feed)
    Given there is an open issue "Restore deleted species"

    When I go to the open issues page
    Then I should see "Restore deleted species"

    When I follow "Restore deleted species"
    And I follow "Edit"
    And I fill in "issue_title" with "Restore deleted genera"
    And I fill in "issue_description" with "The genera: #7554, #8863"
    And I fill in "edit_summary" with "added info"
    And I press "Save"
    Then I should see "Successfully updated issue"
    And I should see "The genera: #7554, #8863"

    When I go to the open issues page
    Then I should see "Restore deleted genera"
    And I should not see "Restore deleted species"

    When I go to the activity feed
    Then I should see "Archibald edited the issue Restore deleted genera" within the activity feed
    And I should see "added info"

  Scenario: Flagging an issue with "Help wanted" and show notice in the nomen synopsis
    Given there is an open issue "Important fix"

    When I go to the catalog
    Then I should not see "Help Wanted" within the page header

    When I go to the open issues page
    Then I should not see "One or more open issues are tagged as 'Help wanted'"
    And I should not see "Important fix Help wanted!"

    When I follow "Important fix"
    And I follow "Edit"
    And I check "issue_help_wanted"
    And I press "Save"
    Then I should see "Successfully updated issue"

    When I go to the catalog
    Then I should see "Help Wanted" within the page header

    When I go to the open issues page
    Then I should see "One or more open issues are tagged as 'Help wanted'"
    And I should see "Important fix Help wanted!"

  Scenario: Closing and re-opening an issue (with feed)
    Given there is an open issue "Add taxa from Aldous 2007"

    When I go to the open issues page
    And I follow "Add taxa from Aldous 2007"
    And I follow "Close"
    Then I should see "Successfully closed issue"
    And I should see "Closed issue: Add taxa from Aldous 2007"

    When I go to the activity feed
    Then I should see "Archibald closed the issue Add taxa from Aldous 2007" within the activity feed

    When I go to the open issues page
    Then I should see "There are currently no open issues."

    When I follow "Add taxa from Aldous 2007"
    And I follow "Re-open"
    Then I should see "Successfully re-opened issue"
    And I should see "Open issue: Add taxa from Aldous 2007"

    When I go to the activity feed
    Then I should see "Archibald re-opened the issue Add taxa from Aldous 2007" within the activity feed
