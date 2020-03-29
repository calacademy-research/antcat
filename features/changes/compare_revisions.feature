@papertrail
Feature: Compare revisions
  As an editor of AntCat
  I want to browse previous revisions of items
  So I can see what has been changed

  Background:
    Given I log in as a catalog editor

  # One big scenario for "reasons".
  @javascript
  Scenario: Comparing history item revisions
    Given there is a genus "Atta"

    # Added item.
    When I go to the edit page for "Atta"
    And I add a history item "initial content"
    And WAIT
    And I go to the activity feed
    And I follow the first linked history item
    And I follow "History"
    Then I should see "This item does not have any previous revisions"

    # Edited.
    When I go to the edit page for "Atta"
    And I update the history item to say "second revision content"
    And I go to the activity feed
    And I follow the first linked history item
    And I follow "History"
    Then I should see "Current version"
    And I should see "second revision content"
    And I should not see "initial content"

    When I follow "prev"
    Then I should see "Difference between revisions"
    And I should see "initial content"

    # Deleted.
    When I go to the edit page for "Atta"
    And I click on the edit taxon history item button
    And I will confirm on the next step
    And I click on the delete taxon history item button
    Then I should be on the edit page for "Atta"

    When I go to the activity feed
    And I follow the first "History"
    Then I should see "Version before item was deleted"
    And I should see "second revision content"

    When I follow "cur"
    Then I should see "Difference between revisions"
    And I should see "initial content"

  Scenario: Comparing reference section revisions
    Given there is a reference section with the references_taxt "test"

    When I go to the page of the most recent reference section
    And I follow "History"
    Then I should see "This item does not have any previous revisions"

  @javascript
  Scenario: Comparing revisions with intermediate revisions
    Given there is a genus "Atta"
    And I go to the edit page for "Atta"
    And I add a history item "initial version"
    And I update the history item to say "second version"
    And I update the history item to say "last version"

    When I go to the activity feed
    And I follow the first linked history item
    And I follow "History"
    And I press "Compare selected revisions"
    Then I should see "second version" within the left side of the diff
    And I should see "last version" within the right side of the diff
    And I should not see "initial version"

    When I follow the second "cur"
    Then I should see "initial version" within the left side of the diff
    And I should see "last version" within the right side of the diff
    And I should not see "second version"
