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
