Feature: Commenting
  Background:
    Given I log in as a catalog editor named "Batiatus"
    And a visitor has submitted a feedback
    And I go to the most recent feedback item

  # JavaScript is required for the dirty hack in "... see my comment highlighted ..."
  @javascript
  Scenario: Leaving a comment
    When I write a new comment "Fixed, closing issue."
    And I press "Post Comment"
    Then I should see "Comment was successfully added"
    And I should see "Fixed, closing issue."
    And I should see my comment highlighted in the comments section

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
