Feature: Site notices
  Background:
    Given I log in as a catalog editor named "Batiatus"
    And there is a site notice "A Site Notice" I haven't read yet
    And I go to the users page

  Scenario: Adding a site notice
    When I go to the site notices page
    And I follow "New"
    And I fill in "site_notice_title" with "New AntCat features"
    And I fill in "site_notice_message" with "You would not believe it!"
    And I press "Publish"
    Then I should see "Successfully created site notice"
    And I should see "Added by Batiatus"

  Scenario: Reading a notice marks it as read
    When I go to the users page
    Then I should see an unread site notice

    When I follow "new notice!" within the desktop menu
    And I follow "A Site Notice"
    Then I should see "A Site Notice"
    And I should not see any unread site notices

  Scenario: Mark all as read from the site notices page
    When I go to the site notices page
    Then I should see an unread site notice

    When I follow "Mark all as read"
    Then I should see "All site notices successfully marked as read."
    And I should not see any unread site notices
    And I should not see "Mark all as read"
