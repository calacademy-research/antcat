Feature: Commenting
  Background:
    Given I log in as a catalog editor named "Batiatus"
    And there is an open feedback item
    And I go to the most recent feedback item

  Scenario: Leaving a comment (with feed)
    When I write a new comment "Fixed, closing issue."
    And I press "Post Comment"
    Then I should see "Comment was successfully added"
    And I should see "Fixed, closing issue."

    When I go to the activity feed
    Then I should see "Batiatus commented on the feedback #"

  @javascript
  Scenario: Editing a comment
    When I write a new comment "Helo!"
    And I press "Post Comment"
    Then I should see "Comment was successfully added"
    And I should see my comment highlighted in the comments section
    And I should not see "ago*"

    When I hover the comment
    And I follow "edit"
    And I fill in "comment_body" with "Hello!"
    And I press "Save edited comment"
    Then I should see "Comment was successfully updated"
    And I should see "Hello!"
    And I should see "ago*"
