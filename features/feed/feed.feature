Feature: Feed
  @javascript
  Scenario: Pagination with quirks
    Given I log in as a superadmin
    And activities are paginated with 2 per page
    And there are 5 activity items

    # Using pagination as usual.
    When I go to the activity feed
    Then I should see 2 item in the feed
    And the query string should not contain "page="
    When I follow "3"
    Then the query string should contain "page=3"

    # Deleting an activity items = return to the same page.
    When I follow "2"
    And I hover the first activity item
    And I follow "Delete"
    Then I should see "was successfully deleted"
    And the query string should contain "page=2"

    # Following an activity item link = the ID param doesn't stick around.
    And the query string should not contain "id="
    And I hover the first activity item
    And I follow "Link"
    Then the query string should contain "id="

    # Restore for future tests.
    Given activities are paginated with 30 per page

  @javascript
  Scenario: Pagination with filtering quirks
    Given I am logged in
    And activities are paginated with 2 per page
    And there is an automated activity with the edit summary "[1] fix URL by script"
    And there is an automated activity with the edit summary "[2] fix URL by script"
    And there is an activity with the edit summary "[3] updated pagination"
    And there is an activity with the edit summary "[4] updated pagination"
    And there is an activity with the edit summary "[5] updated pagination"
    And there is an activity with the edit summary "[6] updated pagination"
    And there is an automated activity with the edit summary "[7] fix URL by script"
    And there is an automated activity with the edit summary "[8] fix URL by script"

    When I go to the activity feed
    Then I should see 2 item in the feed
    And I should see "[6] updated pagination"
    And I should see "[5] updated pagination"

    When I follow "2"
    Then I should see 2 item in the feed
    And I should see "[4] updated pagination"
    And I should see "[3] updated pagination"

    When I hover the first activity item
    And I follow "Link"
    Then I should see 2 item in the feed
    And I should see "[4] updated pagination"
    And I should see "[3] updated pagination"

    Given activities are paginated with 30 per page
