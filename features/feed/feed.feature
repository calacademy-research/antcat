@feed
Feature: Feed
  As an AntCat editor
  I want to see what has changed in the database

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: No activities
    When I go to the activity feed
    Then I should see "No activities"

  Scenario: Deleting activities
    Given I log in as a superadmin
    And I add a journal for the feed

    When I go to the activity feed
    Then I should see 1 item in the feed

    When I follow "Delete"
    Then I should see "No activities"

  Scenario: Only superadmins should be able to delete feed items
    Given I add a journal for the feed

    When I go to the activity feed
    Then I should see 1 item in the feed
    And I should not see "Delete"

  Scenario: Pagination with quirks
    Given I log in as a superadmin
    And the activities are paginated with 2 per page
    And there are 5 activity items

    # Using pagination as usual.
    When I go to the activity feed
    Then I should see 2 item in the feed
    And the query string should not contain "page="
    When I follow "3"
    Then the query string should contain "page=3"

    # Deleting an activity items = return to the same page.
    When I follow "2"
    And I follow the first "Delete"
    Then I should see "was successfully deleted"
    And the query string should contain "page=2"

    # Following an activity item link = the ID param doesn't stick around.
    And the query string should not contain "id="
    When I follow the first "link"
    Then the query string should contain "id="

    # Restore for future tests.
    Given the activities are paginated with 30 per page
