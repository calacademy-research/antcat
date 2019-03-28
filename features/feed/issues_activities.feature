@feed
Feature: Feed (issues)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added issue
    When I go to the open issues page
      And I follow "New"
      And I fill in "issue_title" with "Valid?"
      And I fill in "issue_description" with "Ids #999 and #777"
      And I fill in "edit_summary" with "added question"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the issue Valid?" and no other feed items
    And I should see "added question"

  Scenario: Edited issue
    Given there is an open issue for the feed

    When I go to the open issues page
      And I follow "Valid?"
      And I follow "Edit"
      And I fill in "issue_description" with "Are these valid?"
      And I fill in "edit_summary" with "added info"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald edited the issue Valid?" and no other feed items
    And I should see "added info"

  Scenario: Closed an issue
    Given there is an open issue for the feed

    When I go to the open issues page
      And I follow "Valid?"
      And I follow "Close"
    And I go to the activity feed
    Then I should see "Archibald closed the issue Valid?" and no other feed items

  Scenario: Re-opened a closed issue
    Given there is a closed issue for the feed

    When I go to the open issues page
      And I follow "Valid?"
      And I follow "Re-open"
    And I go to the activity feed
    Then I should see "Archibald re-opened the issue Valid?" and no other feed items
