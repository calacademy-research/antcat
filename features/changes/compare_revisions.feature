@feed @papertrail
Feature: Compare revisions
  As an editor of AntCat
  I want to browse previous revisions of items
  So I can see what has been changed

  Background:
    Given I log in as a catalog editor named "Archibald"

  # One big scenario for "reasons".
  @javascript
  Scenario: Comparing history item revisions
    Given there is a genus "Atta"

    # Added item.
    When I go to the edit page for "Atta"
    And I click the "Add History" button
    And I edit the history item to "initial content"
    And I save the history item
    And I wait for a bit
    And I go to the activity feed
    Then I should not see "versions can be compared"

    When I follow the first linked history item
    Then I should see "This item does not have any previous revisions"

    # Edited.
    When I go to the edit page for "Atta"
    And I click the history item
    And I edit the history item to "second revision content"
    And I save the history item
    And I wait for a bit

    When I go to the activity feed
    Then I should see "versions can be compared"

    When I follow the first linked history item
    Then I should see "Current version"
    And I should see "second revision content"
    And I should not see "initial content"

    When I follow "Revision as of"
    Then I should see "Difference between revisions"
    And I should see "initial content"

    # Deleted.
    When I go to the edit page for "Atta"
    And I click the history item
    And I will confirm on the next step
    And I delete the history item
    Then I should be on the edit page for "Atta"

    When I go to the activity feed
    Then I should see "versions can be compared"

    When I follow the first linked history item
    Then I should see "Version before item was deleted"
    And I should see "second revision content"

    When I follow "Revision as of"
    Then I should see "Difference between revisions"
    And I should see "initial content"

  Scenario: Comparing reference section revisions (added only)
    When I add a reference section for the feed
    And I go to the activity feed
    Then I should see "Archibald added the reference section" and no other feed items

    When I follow the first linked reference section
    Then I should see "This item does not have any previous revisions"
