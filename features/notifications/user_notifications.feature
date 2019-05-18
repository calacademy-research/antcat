# TODO DRY

Feature: User notifications
  Background:
    Given I log in as a catalog editor named "Archibald"
    And this user exists
      | name     |
      | Batiatus |

  Scenario: No notifications
    When I go to my notifications page
    Then I should see "No notifications"

  Scenario: Opening the notifications page marks all notifications as seen
    Given I have an unseen notification

    When I go to the references page
    Then I should see "1 new notification!"

    When I go to my notifications page
    Then I should see 1 unread notification
    And I should not see "new notification"

    Given I have another unseen notification
    When I reload the page
    Then I should see 1 unread notification
    And I should see 2 notifications in total

  Scenario: Mentioning users in comments
    # Create issue by a third user.
    And this user exists
      | name          |
      | Captain Flint |
    And there is an open issue "Ghost Stories" created by "Captain Flint"

    # Mention Batiatus in a comment.
    When I go to the issue page for "Ghost Stories"
    And I write a new comment <at Batiatus's id> "you must read Flint's ghost story!"
    And I press "Post Comment"
    And I wait for the "success" message

    # Confirm Batiatus was notified.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald mentioned you in the comment on the issue Ghost Stories"
    And I should only see 1 notification

  Scenario: Notifying creators, and replying to comments (without mentioning their names)
    Given there is an open issue "My Favorite Ants" created by "Batiatus"

    # Comment on an issue created by Batiatus.
    When I go to the issue page for "My Favorite Ants"
    And I write a new comment "Great list, Batiatus!"
    And I press "Post Comment"
    And I wait for the "success" message

    # Confirm Batiatus was notified.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald commented on the issue My Favorite Ants which you created"
    And I should only see 1 notification

    # Reply to Archibald's comment as Batiatus.
    When I go to the issue page for "My Favorite Ants"
    And I follow "reply"
    And I write a reply with the text "Oh, and I've also replied to the submitter's email."
    And I press "Post Reply"
    And I wait for the "success" message

    # Confirm Archibald was notified.
    When I log in as "Archibald"
    And I go to my notifications page
    Then I should see "Batiatus replied to your comment on the issue My Favorite Ants"
    And I should only see 1 notification

  Scenario: Send at most one notification to a user for the same comment
    # Make Batiatus the issue creator and a participant of the discussion.
    Given there is an open issue "My Favorite Ants" created by "Batiatus"
    When I log in as "Batiatus"
    And I go to the issue page for "My Favorite Ants"
    And I write a new comment "I'll add more later."
    And I press "Post Comment"
    And I wait for the "success" message

    # Comment on Batiatus' issue, mention him, reply to him, in a disussion he is active in.
    When I log in as "Archibald"
    And I go to the issue page for "My Favorite Ants"
    And I follow "reply"
    And I write a comment reply <at Batiatus's id> "I love you list already!"
    And I press "Post Reply"
    And I wait for the "success" message

    # Confirm that Batiatus was only mentioned once.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald replied to your comment on the issue My Favorite Ants"
    And I should only see 1 notification

  Scenario: Do not repeat notifications for any given attached/notifier combination
    Given there is an open issue "My Favorite Ants" created by "Batiatus"

    # Edit Batiatus' issue twice.
    And I go to the issue page for "My Favorite Ants"
    And I follow "Edit"
    And I fill in "issue_description" with "Helo @user" followed by the user id of "Batiatus"
    And I press "Save"
    And I wait for the "success" message

    And I follow "Edit"
    And I fill in "issue_description" with "Hello @user" followed by the user id of "Batiatus"
    And I press "Save"
    And I wait for the "success" message

    # Confirm that Batiatus was only mentioned once.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald mentioned you in the issue My Favorite Ants"
    And I should only see 1 notification


  Scenario: Mentioning users in "things" (issue description)
    # Mention Batiatus in the description of an issue.
    When I go to the new issue page
    And I fill in "issue_title" with "Resolve homonyms"
    And I fill in "issue_description" with "@user" followed by the user id of "Batiatus"
    And I press "Save"
    And I wait for the "success" message

    # Confirm Batiatus was notified.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald mentioned you in the issue Resolve homonyms"
    And I should only see 1 notification

  Scenario: Mentioning users in "things" (site notice messages)
    # Mention Batiatus in the message of a site notice.
    When I go to the site notices page
    And I follow "New"
    And I fill in "site_notice_title" with "New AntCat features"
    And I fill in "site_notice_message" with "@user" followed by the user id of "Batiatus"
    And I press "Publish"
    And I wait for the "success" message

    # Confirm Batiatus was notified.
    When I log in as "Batiatus"
    And I go to my notifications page
    Then I should see "Archibald mentioned you in the site notice New AntCat features"
    And I should only see 1 notification
