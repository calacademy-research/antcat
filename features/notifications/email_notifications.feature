Feature: Email notifications
  Background:
    Given I log in as a user named "Quintus"
    And this user exists
      | email               | name     |
      | batiatus@antcat.org | Batiatus |

  Scenario: Receiving emails notifications
    Given there is an open issue "Ghost Stories" created by "Batiatus"
    And "batiatus@antcat.org" should have 0 unread emails

    # Mention Batiatus in a comment.
    When I go to the issue page for "Ghost Stories"
    And I write a new comment <at Batiatus's id> "nice ghost story!"
    And I press "Post Comment"
    And I wait for the "success" message
    And I follow "Logout" within the desktop menu
    Then I should not see "Quintus"

    Then "batiatus@antcat.org" should have 1 unread email
    When "batiatus@antcat.org" opens the email with subject "New notification - antcat.org"
    Then "batiatus@antcat.org" should see "mentioned you in a comment on the" in the email body
