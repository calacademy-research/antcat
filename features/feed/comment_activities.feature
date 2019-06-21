Feature: Feed (comments)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added comment
    Given a visitor has submitted a feedback with the comment "Fix spelling"

    When I go to the most recent feedback item
      And I write a new comment "Fixed."
      And I press "Post Comment"
    And I go to the activity feed
    Then I should see "Archibald commented on the feedback #"
