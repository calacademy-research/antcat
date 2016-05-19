Feature: Comment on user feedback
  As an AntCat editor
  I want to comment on user feedback
  So that editors can track issues

  Background:
    Given I log in as a catalog editor named "Batiatus"
    And a visitor has submitted a feedback with the comment "Fix spelling"
    And I go to the feedback index
    And follow the link of the first feedback

  Scenario: Commenting on an open task
    When I write a new comment "Fixed, closing issue."
    And I press "Post Comment"
    Then I should see "Comment was successfully added"
    And I should see "Fixed, closing issue."

  @javascript
  Scenario: Replying to a comment
    Given I write a new comment "Fixed, closing issue."
    And I press "Post Comment"

    When I follow "reply"
    And I write a reply with the text "Oh, and I've also replied to the submitter's email."
    And I press "Post Reply"
    Then I should see "Comment was successfully added"
    And I should see "Fixed, closing issue."
    And I should see "Oh, and I've also replied to the submitter's email."
